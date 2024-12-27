import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/sudoku_cubit.dart';
import 'dart:async';

class SinglePlayerGamePage extends StatefulWidget {
  const SinglePlayerGamePage({Key? key}) : super(key: key);

  @override
  State<SinglePlayerGamePage> createState() => _SinglePlayerGamePageState();
}

class _SinglePlayerGamePageState extends State<SinglePlayerGamePage> {
  int? selectedRow;
  int? selectedCol;
  Timer? _timer;
  int _timeElapsed = 0;
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SudokuCubit>().startGame(1);
      });
    } catch (e, stackTrace) {
      print('Ошибка при инициализации игры: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Color getCellColor(bool isSelected, bool isInitial, CellState cellState) {
    if (isSelected) return Colors.blue.withOpacity(0.3);
    switch (cellState) {
      case CellState.initial:
        return Colors.grey[200]!;
      case CellState.correct:
        return Colors.green[100]!;
      case CellState.incorrect:
        return Colors.red[100]!;
      default:
        return Colors.white;
    }
  }

  void _showEndGameDialog(BuildContext context, SudokuState state) {
    if (_showingDialog) return;
    _showingDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          state.isComplete ? 'Поздравляем!' : 'Вы проиграли!',
          style: TextStyle(
            color: state.isComplete ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.isComplete 
              ? 'Вы решили судоку за ${state.timeElapsed.inMinutes} мин ${state.timeElapsed.inSeconds % 60} сек!'
              : 'Совершено 3 ошибки'),
            if (!state.isComplete) const SizedBox(height: 8),
            if (!state.isComplete) Text(
              'Время игры: ${state.timeElapsed.inMinutes} мин ${state.timeElapsed.inSeconds % 60} сек',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showingDialog = false;
              context.read<SudokuCubit>().stopTimer();
              context.go('/home');
            },
            child: const Text('На главную'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showingDialog = false;
              context.read<SudokuCubit>().restartGame(1);
            },
            child: const Text('Новая игра'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Одиночная игра'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopTimer();
            context.go('/home');
          },
        ),
      ),
      body: BlocConsumer<SudokuCubit, SudokuState>(
        listener: (context, state) {
          if ((state.isComplete || state.mistakes >= 3) && !_showingDialog) {
            context.read<SudokuCubit>().stopTimer();
            _showEndGameDialog(context, state);
          }
        },
        builder: (context, state) {
          if (state.currentGrid.every((row) => row.every((cell) => cell == 0))) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Таймер и ошибки
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Время: ${state.timeElapsed.inMinutes}:${(state.timeElapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Ошибки: ${state.mistakes}/3',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Сетка судоку
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                        childAspectRatio: 1,
                      ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final row = index ~/ 9;
                        final col = index % 9;
                        final number = state.currentGrid[row][col];
                        final isInitial = state.initialCells[row][col];
                        final isSelected = row == selectedRow && col == selectedCol;

                        return GestureDetector(
                          onTap: isInitial ? null : () {
                            setState(() {
                              selectedRow = row;
                              selectedCol = col;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: getCellColor(
                                isSelected,
                                isInitial,
                                state.cellStates[row][col],
                              ),
                              border: Border(
                                right: BorderSide(
                                  width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
                                  color: Colors.black,
                                ),
                                bottom: BorderSide(
                                  width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
                                  color: Colors.black,
                                ),
                                left: BorderSide(
                                  width: col % 3 == 0 ? 2.0 : 1.0,
                                  color: Colors.black,
                                ),
                                top: BorderSide(
                                  width: row % 3 == 0 ? 2.0 : 1.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                number == 0 ? '' : number.toString(),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: isInitial ? Colors.black : 
                                        state.cellStates[row][col] == CellState.correct ? Colors.green :
                                        state.cellStates[row][col] == CellState.incorrect ? Colors.red :
                                        Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Цифры для ввода
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(9, (index) {
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: selectedRow != null && selectedCol != null
                              ? () {
                                  context.read<SudokuCubit>().makeMove(
                                        selectedRow!,
                                        selectedCol!,
                                        index + 1,
                                      );
                                }
                              : null,
                          child: Text('${index + 1}'),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 