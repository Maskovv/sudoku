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
  final String? error;

  SudokuState({
    required this.currentGrid,
    required this.solvedGrid,
    required this.initialCells,
    List<List<CellState>>? cellStates,
    this.mistakes = 0,
    this.timeElapsed = Duration.zero,
    this.isComplete = false,
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(timeElapsed: Duration(seconds: timer.tick)));
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void makeMove(int row, int col, int number) async {
    if (state.initialCells[row][col]) return;

    final newGrid = List.generate(
      9,
      (i) => List.generate(9, (j) => state.currentGrid[i][j]),
    );

    newGrid[row][col] = number;
    bool isCorrect = state.solvedGrid[row][col] == number;
    int newMistakes = isCorrect ? state.mistakes : state.mistakes + 1;

    if (newMistakes >= 3) {
      stopTimer();
      try {
        await _profileRepository.updateStats(isWin: false);
        emit(state.copyWith(
          currentGrid: newGrid,
          mistakes: newMistakes,
          isComplete: false,
        ));
        return;
      } catch (e) {
        print('Ошибка при сохранении результатов: $e');
      }
    }

    bool isComplete = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (newGrid[i][j] != state.solvedGrid[i][j]) {
          isComplete = false;
          break;
        }
      }
      if (!isComplete) break;
    }

    if (isComplete) {
      stopTimer();
      try {
        await _profileRepository.updateStats(isWin: true);
      } catch (e) {
        print('Ошибка при сохранении результатов: $e');
      }
    }

    emit(state.copyWith(
      currentGrid: newGrid,
      mistakes: newMistakes,
      isComplete: isComplete,
    ));
  }

  void startGame(int difficulty) {
    try {
      final solvedGrid = _repository.generateSolvedGrid();
      final puzzle = _repository.generatePuzzle(difficulty);
      
      final initialCells = List.generate(
        9,
        (i) => List.generate(
          9,
          (j) => puzzle[i][j] != 0,
        ),
      );

      emit(SudokuState(
        currentGrid: puzzle,
        solvedGrid: solvedGrid,
        initialCells: initialCells,
      ));

      startTimer();
    } catch (e) {
      emit(state.copyWith(error: 'Ошибка при генерации судоку: $e'));
    }
  }
}