import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/multiplayer_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiplayerGameState {
  final String gameId;
  final List<List<int>> currentGrid;
  final List<List<int>> solvedGrid;
  final List<List<bool>> initialCells;
  final String? currentTurn;
  final bool isGameStarted;
  final Map<String, int> mistakes;
  final String? winner;
  final bool isGameFinished;
  final String? error;

  MultiplayerGameState({
    required this.gameId,
    List<List<int>>? currentGrid,
    List<List<int>>? solvedGrid,
    List<List<bool>>? initialCells,
    this.currentTurn,
    this.isGameStarted = false,
    Map<String, int>? mistakes,
    this.winner,
    this.isGameFinished = false,
    this.error,
  }) : 
    currentGrid = currentGrid ?? List.generate(9, (_) => List.filled(9, 0)),
    solvedGrid = solvedGrid ?? List.generate(9, (_) => List.filled(9, 0)),
    initialCells = initialCells ?? List.generate(9, (_) => List.filled(9, false)),
    mistakes = mistakes ?? {};

  bool get isWinner => winner == FirebaseAuth.instance.currentUser?.uid;

  MultiplayerGameState copyWith({
    String? gameId,
    List<List<int>>? currentGrid,
    List<List<int>>? solvedGrid,
    List<List<bool>>? initialCells,
    String? currentTurn,
    bool? isGameStarted,
    Map<String, int>? mistakes,
    String? winner,
    bool? isGameFinished,
    String? error,
  }) {
    return MultiplayerGameState(
      gameId: gameId ?? this.gameId,
      currentGrid: currentGrid ?? this.currentGrid,
      solvedGrid: solvedGrid ?? this.solvedGrid,
      initialCells: initialCells ?? this.initialCells,
      currentTurn: currentTurn ?? this.currentTurn,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      mistakes: mistakes ?? this.mistakes,
      winner: winner ?? this.winner,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      error: error,
    );
  }
}

class MultiplayerGameCubit extends Cubit<MultiplayerGameState> {
  final MultiplayerRepository _repository;
  StreamSubscription? _gameSubscription;

  MultiplayerGameCubit(this._repository, String gameId) 
      : super(MultiplayerGameState(gameId: gameId)) {
    _initGame();
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }

  void _initGame() {
    _gameSubscription?.cancel();
    _gameSubscription = _repository.watchGame(state.gameId).listen(
      (gameSnapshot) {
        final gameData = gameSnapshot.data() as Map<String, dynamic>?;
        if (gameData != null) {
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

          emit(state.copyWith(
            currentGrid: currentGrid,
            solvedGrid: solvedGrid,
            initialCells: initialCells,
            currentTurn: gameData['currentTurn'] as String?,
            isGameStarted: gameData['status'] == 'playing',
            isGameFinished: gameData['status'] == 'finished',
            mistakes: Map<String, int>.from(gameData['mistakes'] as Map),
            winner: gameData['winner'] as String?,
          ));
        }
      },
      onError: (error) {
        emit(state.copyWith(error: error.toString()));
      },
    );
  }

  Future<void> makeMove(int row, int col, int number) async {
    if (state.isGameFinished) return;

    try {
      await _repository.makeMove(state.gameId, row, col, number);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> leaveGame() async {
    try {
      await _repository.leaveGame(state.gameId);
      _gameSubscription?.cancel();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
} 