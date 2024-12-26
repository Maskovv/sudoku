import 'dart:math';

class SudokuRepository {
  final Random _random = Random();
  late List<List<int>> _solvedGrid;
  final int n = 3; // размер блока (3x3)
  late List<List<int>> _table;

  List<List<int>> generateSolvedGrid() {
    try {
      print('Начинаем генерацию судоку...');
      _generateBaseTable();
      _mix();
      _solvedGrid = List<List<int>>.generate(
        9,
        (i) => List<int>.from(_table[i]),
      );
      return _solvedGrid;
    } catch (e) {
      print('Ошибка в generateSolvedGrid: $e');
      rethrow;
    }
  }

  void _generateBaseTable() {
    _table = List<List<int>>.generate(n * n, (i) {
      return List<int>.generate(n * n, (j) {
        return ((i * n + i ~/ n + j) % (n * n) + 1);
      });
    });
  }

  void _transpose() {
    _table = List<List<int>>.generate(
      n * n,
      (i) => List<int>.generate(n * n, (j) => _table[j][i]),
    );
  }

  void _swapRowsSmall() {
    int area = _random.nextInt(n);
    int line1 = _random.nextInt(n);
    int line2;
    do {
      line2 = _random.nextInt(n);
    } while (line1 == line2);

    int N1 = area * n + line1;
    int N2 = area * n + line2;
    var temp = _table[N1];
    _table[N1] = _table[N2];
    _table[N2] = temp;
  }

  void _swapColumnsSmall() {
    _transpose();
    _swapRowsSmall();
    _transpose();
  }

  void _swapRowsArea() {
    int area1 = _random.nextInt(n);
    int area2;
    do {
      area2 = _random.nextInt(n);
    } while (area1 == area2);

    for (int i = 0; i < n; i++) {
      int N1 = area1 * n + i;
      int N2 = area2 * n + i;
      var temp = _table[N1];
      _table[N1] = _table[N2];
      _table[N2] = temp;
    }
  }

  void _swapColumnsArea() {
    _transpose();
    _swapRowsArea();
    _transpose();
  }

  void _mix([int amt = 10]) {
    var mixFuncs = [
      _transpose,
      _swapRowsSmall,
      _swapColumnsSmall,
      _swapRowsArea,
      _swapColumnsArea
    ];
    
    for (int i = 0; i < amt; i++) {
      mixFuncs[_random.nextInt(mixFuncs.length)]();
    }
  }

  List<List<int>> generatePuzzle(int difficulty) {
    try {
      print('Генерация игровой сетки...');
      var puzzle = List<List<int>>.generate(
        n * n,
        (i) => List<int>.from(_solvedGrid[i]),
      );

      int cellsToRemove;
      switch (difficulty) {
        case 1:
          cellsToRemove = 30; // Легкий
          break;
        case 2:
          cellsToRemove = 40; // Средний
          break;
        case 3:
          cellsToRemove = 50; // Сложный
          break;
        default:
          cellsToRemove = 35;
      }

      var positions = <Point<int>>[];
      for (int i = 0; i < n * n; i++) {
        for (int j = 0; j < n * n; j++) {
          positions.add(Point(i, j));
        }
      }
      positions.shuffle(_random);

      int removed = 0;
      for (var point in positions) {
        if (removed >= cellsToRemove) break;
        
        if (puzzle[point.x][point.y] != 0) {
          int backup = puzzle[point.x][point.y];
          puzzle[point.x][point.y] = 0;

          if (_isValidPuzzle(puzzle)) {
            removed++;
          } else {
            puzzle[point.x][point.y] = backup;
          }
        }
      }

      return puzzle;
    } catch (e) {
      print('Ошибка в generatePuzzle: $e');
      rethrow;
    }
  }

  bool _isValidPuzzle(List<List<int>> puzzle) {
    return true; // Упрощенная проверка для тестирования
  }

  bool _isValidPlacement(List<List<int>> grid, int row, int col, int num) {
    for (int x = 0; x < n * n; x++) {
      if (grid[row][x] == num) return false;
    }

    for (int x = 0; x < n * n; x++) {
      if (grid[x][col] == num) return false;
    }

    int startRow = row - row % n;
    int startCol = col - col % n;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }

    return true;
  }
}