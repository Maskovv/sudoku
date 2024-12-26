import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/profile_repository.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class GameState {
  final bool isGameEnded;
  final bool showEndGameMenu;
  final bool isWinner;
  final Duration timeElapsed;

  const GameState({
    this.isGameEnded = false,
    this.showEndGameMenu = false,
    this.isWinner = false,
    this.timeElapsed = Duration.zero,
  });

  GameState copyWith({
    bool? isGameEnded,
    bool? showEndGameMenu,
    bool? isWinner,
    Duration? timeElapsed,
  }) {
    return GameState(
      isGameEnded: isGameEnded ?? this.isGameEnded,
      showEndGameMenu: showEndGameMenu ?? this.showEndGameMenu,
      isWinner: isWinner ?? this.isWinner,
      timeElapsed: timeElapsed ?? this.timeElapsed,
    );
  }
}

class GameInitial extends GameState {}
class GameLoading extends GameState {}
class GameRunning extends GameState {}
class GamePaused extends GameState {}
class GameFinished extends GameState {}

class GameCubit extends Cubit<GameState> {
  Timer? _timer;
  final ProfileRepository _profileRepository;
  final String userId;
  bool _isUpdatingStats = false;
  bool _isGameFinished = false;

  GameCubit(this._profileRepository, this.userId) : super(const GameState());

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void startGame() {
    _isGameFinished = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGameFinished) {
        emit(state.copyWith(
          timeElapsed: Duration(seconds: timer.tick),
        ));
      }
    });
  }

  Future<void> finishGame(bool isWin) async {
    if (!_isGameFinished && !_isUpdatingStats) {
      _isGameFinished = true;
      _timer?.cancel();
      _isUpdatingStats = true;
      
      try {
        await _profileRepository.updateStats(isWin: isWin, uid: userId);
        emit(state.copyWith(
          isGameEnded: true,
          showEndGameMenu: true,
          isWinner: isWin,
        ));
      } catch (e) {
        print('Ошибка при обновлении статистики: $e');
      } finally {
        _isUpdatingStats = false;
      }
    }
  }

  void closeEndGameMenu() {
    _timer?.cancel();
    _isGameFinished = false;
    emit(const GameState());
  }

  void resetGame() {
    _timer?.cancel();
    _isGameFinished = false;
    _isUpdatingStats = false;
    emit(const GameState());
  }
} 