import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/profile_repository.dart';
import '../models/user_profile.dart';
import 'auth_state.dart';
import '../repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileRepository _profileRepository;

  AuthCubit(this._profileRepository) : super(const AuthInitial()) {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        final profile = await _profileRepository.getProfile(user.uid);
        if (profile == null) {
          await _profileRepository.createProfile(
            user.uid,
            user.email ?? '',
            user.email?.split('@')[0] ?? 'User',
          );
        }
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.uid,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
      ));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Пользователь с такой почтой не найден';
          break;
        case 'wrong-password':
          errorMessage = 'Неверный пароль';
          break;
        case 'invalid-email':
          errorMessage = 'Неверный формат email';
          break;
        default:
          errorMessage = 'Произошла ошибка при входе: ${e.message}';
      }
      emit(state.copyWith(error: errorMessage));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      print('Starting signup process...');
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('User created with ID: ${userCredential.user?.uid}');
      
      if (userCredential.user != null) {
        print('Creating profile...');
        await _profileRepository.createProfile(
          userCredential.user!.uid,
          email,
          email.split('@')[0],
        );
        print('Profile created successfully');
        
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          userId: userCredential.user!.uid,
        ));
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Эта почта уже используется';
          break;
        case 'weak-password':
          errorMessage = 'Слишком простой пароль';
          break;
        case 'invalid-email':
          errorMessage = 'Неверный формат email';
          break;
        default:
          errorMessage = 'Произошла ошибка при регистрации: ${e.message}';
      }
      emit(state.copyWith(
        error: errorMessage,
        isLoading: false,
      ));
    } catch (e) {
      print('Error during signup: $e');
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> register(String email, String password) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      
      print('AuthCubit: Начало регистрации');
      final auth = AuthRepository();
      final credentials = await auth.register(email, password);
      
      if (credentials.user != null) {
        print('AuthCubit: Создание профиля пользователя');
        await _profileRepository.createProfile(
          credentials.user!.uid,
          email,
          email.split('@')[0],
        );
        print('AuthCubit: Профиль создан успешно');
        
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          userId: credentials.user!.uid,
        ));
      }
    } catch (e) {
      print('AuthCubit: Ошибка при регистрации: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}