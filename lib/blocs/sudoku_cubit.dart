import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/sudoku_repository.dart';
import '../repositories/profile_repository.dart';
import 'dart:async';

class SudokuState {
  final List<List<int>> currentGrid; // Текущая сетка
  final List<List<int>> solvedGrid;  // Решенная сетка
  final List<List<bool>> initialCells; // Изначальные ячейки
  final List<List<CellState>> cellStates; // Добавляем состояния ячеек
  final int mistakes;
  final Duration timeElapsed;
  final bool isComplete;
  final bool isGameOver;
  final String? error;

  SudokuState({
    required this.currentGrid,
    required this.solvedGrid,
    required this.initialCells,
    List<List<CellState>>? cellStates,
    this.mistakes = 0,
    this.timeElapsed = Duration.zero,
    this.isComplete = false,
    this.isGameOver = false,
    this.error,
  }) : cellStates = cellStates ?? List.generate(
         9,
         (_) => List.filled(9, CellState.empty),
       );

  SudokuState copyWith({
    List<List<int>>? currentGrid,
    List<List<int>>? solvedGrid,
    List<List<bool>>? initialCells,
    int? mistakes,
    Duration? timeElapsed,
    bool? isComplete,
    bool? isGameOver,
    String? error,
  }) {
    return SudokuState(
      currentGrid: currentGrid ?? this.currentGrid,
      solvedGrid: solvedGrid ?? this.solvedGrid,
      initialCells: initialCells ?? this.initialCells,
      cellStates: this.cellStates,
      mistakes: mistakes ?? this.mistakes,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      isComplete: isComplete ?? this.isComplete,
      isGameOver: isGameOver ?? this.isGameOver,
      error: error,
    );
  }
}

enum CellState {
  empty,
  correct,
  incorrect,
  initial
}

class SudokuCubit extends Cubit<SudokuState> {
  final SudokuRepository _repository;
  final ProfileRepository _profileRepository;
  Timer? _timer;

  SudokuCubit(this._repository, this._profileRepository) : super(SudokuState(
    currentGrid: List.generate(9, (_) => List.filled(9, 0)),
    solvedGrid: List.generate(9, (_) => List.filled(9, 0)),
    initialCells: List.generate(9, (_) => List.filled(9, false)),
  ));

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(timeElapsed: Duration(seconds: timer.tick)));
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void makeMove(int row, int col, int number) {
    if (state.initialCells[row][col]) return;

    final newGrid = List.generate(
      9,
      (i) => List.generate(9, (j) => state.currentGrid[i][j]),
    );

    newGrid[row][col] = number;
    bool isCorrect = state.solvedGrid[row][col] == number;

    emit(state.copyWith(
      currentGrid: newGrid,
      mistakes: isCorrect ? state.mistakes : state.mistakes + 1,
    ));

    // Проверка на победу
    checkForWin(newGrid);
  }

  void startGame(int difficulty) {
    final solvedGrid = _repository.generateSolvedGrid();
    final puzzle = _repository.generatePuzzle(difficulty);

    emit(SudokuState(
      currentGrid: puzzle,
      solvedGrid: solvedGrid,
      initialCells: List.generate(9, (i) => List.generate(9, (j) => puzzle[i][j] != 0)),
      timeElapsed: Duration.zero,
    ));

    startTimer();
  }

  void resetGame() {
    _timer?.cancel();
    emit(SudokuState(
      currentGrid: List.generate(9, (_) => List.filled(9, 0)),
      solvedGrid: List.generate(9, (_) => List.filled(9, 0)),
      initialCells: List.generate(9, (_) => List.filled(9, false)),
      timeElapsed: Duration.zero,
      isComplete: false,
      mistakes: 0
    ));
  }

  void restartGame(int difficulty) {
    resetGame();
    startGame(difficulty);
  }

  void checkForWin(List<List<int>> grid) {
    bool isComplete = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] != state.solvedGrid[i][j]) {
          isComplete = false;
          break;
        }
      }
      if (!isComplete) break;
    }

    if (isComplete || state.mistakes >= 3) {
      stopTimer();
      // Добавляем обновле��ие статистики
      _profileRepository.updateStats(
        isWin: isComplete && state.mistakes < 3,
      );
      emit(state.copyWith(
        isComplete: isComplete,
        isGameOver: true
      ));
    }
  }

  void finishGame() {
    _timer?.cancel();
  }
}