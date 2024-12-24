import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/multiplayer_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiplayerState {
  final String? gameId;
  final String? error;
  final bool isSearching;
  final List<List<int>> currentGrid;
  final List<List<int>> solvedGrid;
  final List<List<bool>> initialCells;
  final String? currentTurn;
  final bool isGameStarted;
  final Map<String, int> mistakes;
  final String? winner;
  final bool isGameFinished;

  MultiplayerState({
    this.gameId,
    this.error,
    this.isSearching = false,
    List<List<int>>? currentGrid,
    List<List<int>>? solvedGrid,
    List<List<bool>>? initialCells,
    this.currentTurn,
    this.isGameStarted = false,
    Map<String, int>? mistakes,
    this.winner,
    this.isGameFinished = false,
  }) : 
    currentGrid = currentGrid ?? List.generate(9, (_) => List.filled(9, 0)),
    solvedGrid = solvedGrid ?? List.generate(9, (_) => List.filled(9, 0)),
    initialCells = initialCells ?? List.generate(9, (_) => List.filled(9, false)),
    mistakes = mistakes ?? {};

  bool get isWinner => winner == FirebaseAuth.instance.currentUser?.uid;

  MultiplayerState copyWith({
    String? gameId,
    String? error,
    bool? isSearching,
    List<List<int>>? currentGrid,
    List<List<int>>? solvedGrid,
    List<List<bool>>? initialCells,
    String? currentTurn,
    bool? isGameStarted,
    Map<String, int>? mistakes,
    String? winner,
    bool? isGameFinished,
  }) {
    return MultiplayerState(
      gameId: gameId ?? this.gameId,
      error: error,
      isSearching: isSearching ?? this.isSearching,
      currentGrid: currentGrid ?? this.currentGrid,
      solvedGrid: solvedGrid ?? this.solvedGrid,
      initialCells: initialCells ?? this.initialCells,
      currentTurn: currentTurn ?? this.currentTurn,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      mistakes: mistakes ?? this.mistakes,
      winner: winner ?? this.winner,
      isGameFinished: isGameFinished ?? this.isGameFinished,
    );
  }
}

class MultiplayerCubit extends Cubit<MultiplayerState> {
  final MultiplayerRepository _repository;
  StreamSubscription? _gameSubscription;

  MultiplayerCubit(this._repository) : super(MultiplayerState());

  void initGame(String gameId) {
    _initGame(gameId);
  }

  void _initGame(String gameId) {
    _gameSubscription?.cancel();
    _gameSubscription = _repository.watchGame(gameId).listen(
      (gameSnapshot) {
        try {
          final gameData = gameSnapshot.data() as Map<String, dynamic>?;
          if (gameData != null) {
            print('Статус игры: ${gameData['status']}');
            
            final newState = state.copyWith(
              gameId: gameId,
              isGameStarted: gameData['status'] == 'playing',
              isGameFinished: gameData['status'] == 'finished',
              isSearching: gameData['status'] == 'waiting',
              mistakes: Map<String, int>.from(gameData['mistakes'] as Map),
              winner: gameData['winner'] as String?,
            );

            if (gameData['currentGrid'] != null) {
              final currentGrid = List<List<int>>.from(
                (gameData['currentGrid'] as List).map(
                  (row) => List<int>.from(row),
                ),
              );
              final solvedGrid = List<List<int>>.from(
                (gameData['solvedGrid'] as List).map(
                  (row) => List<int>.from(row),
                ),
              );
              final puzzle = List<List<int>>.from(
                (gameData['puzzle'] as List).map(
                  (row) => List<int>.from(row),
                ),
              );
              final initialCells = List<List<bool>>.generate(
                9,
                (i) => List<bool>.generate(
                  9,
                  (j) => puzzle[i][j] != 0,
                ),
              );

              emit(newState.copyWith(
                currentGrid: currentGrid,
                solvedGrid: solvedGrid,
                initialCells: initialCells,
              ));
            } else {
              emit(newState);
            }
          }
        } catch (e) {
          print('Ошибка при обработке данных игры: $e');
          emit(state.copyWith(error: e.toString()));
        }
      },
      onError: (error) {
        print('Ошибка при получении данных игры: $error');
        emit(state.copyWith(error: error.toString()));
      },
      cancelOnError: false,
    );
  }

  Future<void> startSearching() async {
    try {
      emit(state.copyWith(
        isSearching: true, 
        error: null,
        gameId: null,
      ));

      print('Начинаем поиск игры...');
      final gameId = await _repository.createGame();
      
      print('Игра найдена/создана, ID: $gameId');
      emit(state.copyWith(
        gameId: gameId,
        isSearching: true,
      ));

      _initGame(gameId);

      await Future.delayed(Duration(seconds: 30));
      
      if (state.isSearching && !state.isGameStarted) {
        print('Таймаут поиска игры');
        await _repository.leaveGame(gameId);
        emit(MultiplayerState(error: 'Не удалось найти игру. Попробуйте еще раз.'));
      }

    } catch (e) {
      print('Ошибка при поиске игры: $e');
      emit(state.copyWith(
        error: 'Ошибка при поиске игры: $e',
        isSearching: false,
      ));
    }
  }

  Future<void> makeMove(int row, int col, int number) async {
    if (state.gameId == null || state.isGameFinished) return;

    try {
      await _repository.makeMove(state.gameId!, row, col, number);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> leaveGame() async {
    if (state.gameId == null) return;

    try {
      await _repository.leaveGame(state.gameId!);
      _gameSubscription?.cancel();
      emit(MultiplayerState());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
} 