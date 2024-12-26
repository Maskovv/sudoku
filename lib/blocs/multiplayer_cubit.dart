import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/multiplayer_repository.dart';
import 'dart:async';

class MultiplayerState {
  final bool isLoading;
  final String? error;
  final bool isGameStarted;
  final String gameId;
  final List<List<int>> solvedGrid;

  const MultiplayerState({
    this.isLoading = true,
    this.error,
    this.isGameStarted = false,
    required this.gameId,
    required this.solvedGrid,
  });

  get isSearching => null;

  MultiplayerState copyWith({
    bool? isLoading,
    String? error,
    bool? isGameStarted,
    String? gameId,
    List<List<int>>? solvedGrid,
  }) {
    return MultiplayerState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      gameId: gameId ?? this.gameId,
      solvedGrid: solvedGrid ?? this.solvedGrid,
    );
  }
}

class MultiplayerCubit extends Cubit<MultiplayerState> {
  final MultiplayerRepository _repository;

  MultiplayerCubit(this._repository) : super(MultiplayerState(
    gameId: '',
    solvedGrid: List.generate(9, (_) => List.filled(9, 0)),
  ));

  Timer? _searchTimer;

  void startSearching() {
    emit(state.copyWith(isLoading: true));
    
    _repository.findAvailableGame().then((gameId) {
      if (gameId != null) {
        emit(state.copyWith(isGameStarted: true, gameId: gameId));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Не удалось найти противника.'));
      }
    });
  }

  void leaveGame() {
    _searchTimer?.cancel(); // Отменяем таймер при выходе из игры
    emit(MultiplayerState(
      gameId: '',
      solvedGrid: List.generate(9, (_) => List.filled(9, 0)),
    )); // Сбрасываем состояние игры
  }

  Future<void> makeMove(int row, int col, int number) async {
    await _repository.makeMove(state.gameId, row, col, number);
    // Обновите состояние после хода
  }
}