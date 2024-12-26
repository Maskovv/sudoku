import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sudoku_repository.dart';

class MultiplayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SudokuRepository sudokuRepository;

  MultiplayerRepository(this.sudokuRepository);

  Future<void> createGame() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Пользователь не авторизован');

    await _firestore.collection('games').add({
      'player1': currentUser.uid,
      'player2': null,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> joinGame(String gameId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Пользователь не авторизован');

    await _firestore.collection('games').doc(gameId).update({
      'player2': currentUser.uid,
      'status': 'playing',
    });
  }

  Stream<DocumentSnapshot> watchGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots();
  }

  Future<void> makeMove(String gameId, int row, int col, int number) async {
    await _firestore.collection('games').doc(gameId).update({
      'currentGrid.$row.$col': number,
    });
  }

  Future<void> leaveGame(String gameId) async {
    final userId = _auth.currentUser?.uid;

    if (userId != null) {
      await _firestore.collection('games').doc(gameId).update({
        'status': 'finished',
        'winner': null,
        'losers': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<String?> findAvailableGame() async {
    try {
      final querySnapshot = await _firestore.collection('games')
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // Возвращаем ID первой доступной игры
      }
      return null; // Если доступных игр нет
    } catch (e) {
      print('Ошибка при поиске доступной игры: $e');
      return null; // Возвращаем null в случае ошибки
    }
  }
}