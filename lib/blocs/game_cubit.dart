import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GameState {}

class GameInitial extends GameState {}
class GameLoading extends GameState {}
class GameRunning extends GameState {}
class GamePaused extends GameState {}
class GameFinished extends GameState {}

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameInitial());

  void startGame() {
    emit(GameRunning());
  }

  void pauseGame() {
    emit(GamePaused());
  }

  void resumeGame() {
    emit(GameRunning());
  }

  void finishGame() {
    emit(GameFinished());
  }
} 