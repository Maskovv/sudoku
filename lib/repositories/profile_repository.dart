import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProfile(String uid, String email, String username) async {
    try {
      print('Creating profile for user: $uid');
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'gamesPlayed': 0,
        'gamesWon': 0,
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
      final doc = await _firestore.collection('profiles').doc(uid).get();
      print('Getting profile for uid: $uid'); 
      print('Document exists: ${doc.exists}'); 
      if (doc.exists) {
        print('Document data: ${doc.data()}');
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      throw Exception('Failed to get profile: $e');
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
      if (user == null) {
        print('Пользователь не авторизован');
        return;
      }

      final userDoc = _firestore.collection('profiles').doc(uid ?? user.uid);
      final userData = await userDoc.get();
      print('Обновляем статистику для пользователя: ${uid ?? user.uid}');

      if (userData.exists) {
        await userDoc.update({
          'totalGames': FieldValue.increment(1),
          'wins': FieldValue.increment(isWin ? 1 : 0),
          'losses': FieldValue.increment(isWin ? 0 : 1),
        });
        print('Статистика успешно обновлена');
      } else {
        print('Профиль пользователя не найден');
      }
    } catch (e) {
      print('Ошибка при обновлении статистики: $e');
      throw e;
    }
  }
} 