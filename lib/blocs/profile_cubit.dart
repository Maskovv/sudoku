import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/profile_repository.dart';
import '../models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileCubit(this._profileRepository) : super(ProfileState());

  Future<void> loadProfile(String uid) async {
    emit(ProfileState(isLoading: true));
    try {
      print('ProfileCubit: Loading profile for uid: $uid');
      final profile = await _profileRepository.getProfile(uid);
      print('ProfileCubit: Loaded profile: $profile');
      emit(ProfileState(profile: profile));
    } catch (e) {
      print('ProfileCubit: Error loading profile: $e');
      emit(ProfileState(error: e.toString()));
    }
  }

  Future<void> createProfile(String uid, String nickname) async {
    emit(ProfileState(isLoading: true));
    try {
      final email = _auth.currentUser?.email ?? '';
      await _profileRepository.createProfile(uid, email, nickname);
      await loadProfile(uid);
    } catch (e) {
      emit(ProfileState(error: e.toString()));
    }
  }

  Future<void> updateStats({
    required String uid,
    bool puzzleSolved = false,
    bool correctlySolved = false,
    bool competitiveWin = false,
  }) async {
    try {
      await _profileRepository.updateGameStats(
        uid: uid,
        isWin: correctlySolved,
      );
      await loadProfile(uid);
    } catch (e) {
      emit(ProfileState(error: e.toString()));
    }
  }
}