import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/game_cubit.dart';
import '../blocs/sudoku_cubit.dart';
import '../blocs/auth_cubit.dart';
import '../repositories/profile_repository.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameCubit>().startGame();
      context.read<SudokuCubit>().startGame(1);
    });
  }

  void _showEndGameDialog(BuildContext context, GameState state) {
    if (_showingDialog) return;
    _showingDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(state.isWinner ? 'Победа!' : 'Поражение'),
          content: Text(state.isWinner ? 'Поздравляем!' : 'Попробуйте еще раз'),
          actions: [
            TextButton(
              onPressed: () {
                _showingDialog = false;
                Navigator.of(dialogContext).pop();
                context.read<GameCubit>().closeEndGameMenu();
                context.go('/home');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listenWhen: (previous, current) => 
        !previous.showEndGameMenu && current.showEndGameMenu,
      listener: (context, state) {
        if (state.showEndGameMenu) {
          _showEndGameDialog(context, state);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Игра'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (!state.isGameEnded) {
                  await context.read<GameCubit>().finishGame(false);
                }
                context.go('/home');
              },
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Время: ${state.timeElapsed.inMinutes}:${(state.timeElapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: BlocBuilder<SudokuCubit, SudokuState>(
                  builder: (context, sudokuState) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                        childAspectRatio: 1,
                      ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final row = index ~/ 9;
                        final col = index % 9;
                        final number = sudokuState.currentGrid[row][col];
                        final isInitial = sudokuState.initialCells[row][col];

                        return GestureDetector(
                          onTap: isInitial ? null : () {
                            // Показать диалог выбора числа
                            showDialog(
                              context: context,
                              builder: (context) => NumberPickerDialog(
                                onNumberSelected: (number) {
                                  context.read<SudokuCubit>().makeMove(row, col, number);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: isInitial ? Colors.grey[200] : Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                number == 0 ? '' : number.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NumberPickerDialog extends StatelessWidget {
  final Function(int) onNumberSelected;

  const NumberPickerDialog({Key? key, required this.onNumberSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Wrap(
        children: List.generate(9, (index) {
          final number = index + 1;
          return TextButton(
            onPressed: () => onNumberSelected(number),
            child: Text(number.toString()),
          );
        }),
      ),
    );
  }
} 