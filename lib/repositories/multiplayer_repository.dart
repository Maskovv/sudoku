import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sudoku_repository.dart';

class MultiplayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SudokuRepository _sudokuRepository = SudokuRepository();

  Future<String> createGame() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Пользователь не авторизован');

      print('Поиск существующих игр...');

      // Сначала ищем существующую игру
      final existingGame = await _firestore
          .collection('games')
          .where('status', isEqualTo: 'waiting')
          .where('player1', isNotEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (existingGame.docs.isNotEmpty) {
        print('Найдена существующая игра, присоединяемся...');
        final gameId = existingGame.docs.first.id;
        await joinGame(gameId);
        return gameId;
      }

      print('Существующих игр не найдено, создаем новую...');
      
      // Создаем новую игру только если не нашли существующую
      final gameRef = await _firestore.collection('games').add({
        'player1': currentUser.uid,
        'player2': null,
        'status': 'waiting',
        'currentTurn': currentUser.uid,
        'mistakes': {
          currentUser.uid: 0,
        },
        'winner': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Создана новая игра с ID: ${gameRef.id}');
      return gameRef.id;
    } catch (e) {
      print('Ошибка при создании/поиске игры: $e');
      throw e;
    }
  }

  Future<void> joinGame(String gameId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Пользователь не авторизован');

      print('Присоединение к игре...');
      
      final solvedGrid = _sudokuRepository.generateSolvedGrid();
      final puzzle = _sudokuRepository.generatePuzzle(45);

      await _firestore.collection('games').doc(gameId).update({
        'player2': currentUser.uid,
        'status': 'playing',
        'mistakes.${currentUser.uid}': 0,
        'puzzle': puzzle,
        'solvedGrid': solvedGrid,
        'currentGrid': puzzle,
      });

      print('Успешно присоединились к игре');
    } catch (e) {
      print('Ошибка при присоединении к игре: $e');
      throw e;
    }
  }

  Future<void> makeMove(String gameId, int row, int col, int number) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Пользователь не авторизован');

      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      final gameData = gameDoc.data();

      if (gameData == null) throw Exception('Игра не найдена');
      if (gameData['status'] != 'playing') return;

      final solvedGrid = List<List<int>>.from(
        (gameData['solvedGrid'] as List).map((row) => List<int>.from(row)),
      );
      
      bool isCorrect = solvedGrid[row][col] == number;

      if (!isCorrect) {
        await _firestore.collection('games').doc(gameId).update({
          'mistakes.$currentUser.uid': FieldValue.increment(1),
        });

        final currentMistakes = (gameData['mistakes'][currentUser.uid] ?? 0) + 1;
        if (currentMistakes >= 3) {
          final opponent = gameData['player1'] == currentUser.uid 
              ? gameData['player2'] 
              : gameData['player1'];

          await _firestore.collection('games').doc(gameId).update({
            'status': 'finished',
            'winner': opponent,
          });
        }
      } else {
        final currentGrid = List<List<int>>.from(
          (gameData['currentGrid'] as List).map((row) => List<int>.from(row)),
        );
        currentGrid[row][col] = number;

        bool isComplete = true;
        for (int i = 0; i < 9 && isComplete; i++) {
          for (int j = 0; j < 9; j++) {
            if (currentGrid[i][j] != solvedGrid[i][j]) {
              isComplete = false;
              break;
            }
          }
        }

        if (isComplete) {
          await _firestore.collection('games').doc(gameId).update({
            'status': 'finished',
            'winner': currentUser.uid,
          });
        } else {
          await _firestore.collection('games').doc(gameId).update({
            'currentGrid': currentGrid,
          });
        }
      }
    } catch (e) {
      print('Ошибка при совершении хода: $e');
      throw e;
    }
  }

  Stream<DocumentSnapshot> watchGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots();
  }

  Future<void> leaveGame(String gameId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      final gameData = gameDoc.data();

      if (gameData != null && gameData['status'] == 'playing') {
        final opponent = gameData['player1'] == currentUser.uid 
            ? gameData['player2'] 
            : gameData['player1'];

        await _firestore.collection('games').doc(gameId).update({
          'status': 'finished',
          'winner': opponent,
        });
      }
    } catch (e) {
      print('Ошибка при выходе из игры: $e');
      throw e;
    }
  }
} 