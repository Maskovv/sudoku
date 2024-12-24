class SudokuState {
  final List<List<int>> grid;
  final bool isComplete;
  final Duration timeElapsed;

  const SudokuState({
    required this.grid,
    this.isComplete = false,
    this.timeElapsed = Duration.zero,
  });
} 