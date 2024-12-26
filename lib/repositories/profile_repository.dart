import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProfile(String uid, String email, String username) async {
    try {
      print('Creating profile for user: $uid');
      await _firestore.collection('profiles').doc(uid).set({
        'uid': uid,
        'email': email,
        'nickname': username,
        'totalGames': 0,
        'wins': 0,
        'losses': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Profile created successfully');
    } catch (e) {
      print('Error creating profile: $e');
      throw e;
    }
  }

  Future<UserProfile?> getProfile(String uid) async {
    try {
      print('ProfileRepository: Getting profile for uid: $uid');
      final doc = await _firestore.collection('profiles').doc(uid).get();
      print('ProfileRepository: Document exists: ${doc.exists}');
      print('ProfileRepository: Document data: ${doc.data()}');
      
      if (doc.exists) {
        final profile = UserProfile.fromMap({
          ...doc.data()!,
          'uid': uid,
        });
        print('ProfileRepository: Created profile object: $profile');
        return profile;
      }
      return null;
    } catch (e) {
      print('ProfileRepository: Error getting profile: $e');
      throw e;
    }
  }

  Future<void> updateGameStats({
    required String uid,
    bool isWin = false,
  }) async {
    try {
      final docRef = _firestore.collection('profiles').doc(uid);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw Exception('Profile not found');
        }
        
        final currentProfile = UserProfile.fromMap(doc.data()!);
        final updatedProfile = UserProfile(
          uid: currentProfile.uid,
          email: currentProfile.email,
          nickname: currentProfile.nickname,
          totalGames: currentProfile.totalGames + 1,
          wins: currentProfile.wins + (isWin ? 1 : 0),
          losses: currentProfile.losses + (isWin ? 0 : 1),
        );
        
        transaction.set(docRef, updatedProfile.toMap(), SetOptions(merge: true));
      });
    } catch (e) {
      print('Error updating stats: $e');
      throw Exception('Failed to update stats: $e');
    }
  }

  Future<void> updateStats({
    required bool isWin,
    String? uid,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null && uid == null) {
        print('Пользователь не авторизован');
        return;
      }

      final userDoc = _firestore.collection('profiles').doc(uid ?? user!.uid);
      
      // Используем транзакцию для атомарного обновления
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) {
          throw Exception('Профиль не найден');
        }

        final currentData = snapshot.data()!;
        final totalGames = (currentData['totalGames'] ?? 0) + 1;
        final wins = (currentData['wins'] ?? 0) + (isWin ? 1 : 0);
        final losses = (currentData['losses'] ?? 0) + (isWin ? 0 : 1);

        transaction.update(userDoc, {
          'totalGames': totalGames,
          'wins': wins,
          'losses': losses,
        });
      });

      print('Статистика успешно обновлена: победа=$isWin, uid=${uid ?? user!.uid}');
    } catch (e) {
      print('Ошибка при обновлении статистики: $e');
      throw e;
    }
  }

  Future<void> updateProfile(String userId, {int wins = 0, int losses = 0}) async {
    print("Обновление профиля для пользователя: $userId, Победы: $wins, Поражения: $losses");
    final userRef = _firestore.collection('profiles').doc(userId);

    // Получаем текущие данные пользователя
    final userDoc = await userRef.get();
    if (userDoc.exists) {
      final data = userDoc.data() ?? {};
      final currentWins = data['wins'] ?? 0;
      final currentLosses = data['losses'] ?? 0;

      // Обновляем данные
      await userRef.update({
        'wins': currentWins + wins,
        'losses': currentLosses + losses,
      });
    } else {
      // Если документа нет, создаем новый
      await userRef.set({
        'wins': wins,
        'losses': losses,
      });
    }
  }
} 