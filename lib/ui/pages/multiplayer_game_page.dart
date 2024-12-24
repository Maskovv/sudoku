import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/multiplayer_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiplayerGamePage extends StatefulWidget {
  final String gameId;

  const MultiplayerGamePage({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    context.read<MultiplayerCubit>().initGame(widget.gameId);
  }

  @override
  void dispose() {
    context.read<MultiplayerCubit>().leaveGame();
    super.dispose();
  }

  Color getCellColor(bool isSelected, bool isInitial) {
    if (isSelected) return Colors.blue.withOpacity(0.3);
    if (isInitial) return Colors.grey[200]!;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocConsumer<MultiplayerCubit, MultiplayerState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }

        if (state.isGameFinished) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(
                state.isWinner ? 'Победа!' : 'Поражение',
                style: TextStyle(
                  color: state.isWinner ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.isWinner 
                        ? 'Поздравляем! Вы выиграли!'
                        : 'К сожалению, вы проиграли.',
                  ),
                  if (state.mistakes[currentUser?.uid] == 3)
                    const Text('Совершено 3 ошибки'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('На главную'),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/multiplayer-search');
                  },
                  child: const Text('Новая игра'),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        final isMyTurn = state.currentTurn == currentUser?.uid;
        final myMistakes = state.mistakes[currentUser?.uid] ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Онлайн игра'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      isMyTurn ? 'Ваш ход' : 'Ход противника',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isMyTurn ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Ошибки: $myMistakes/3',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                          onTap: isMyTurn && !isInitial ? () {
                            setState(() {
                              selectedRow = row;
                              selectedCol = col;
                            });
                          } : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: getCellColor(isSelected, isInitial),
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
                                  color: isInitial ? Colors.black : Colors.blue,
                                  fontWeight: isInitial ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (isMyTurn) Padding(
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
                                  context.read<MultiplayerCubit>().makeMove(
                                    selectedRow!,
                                    selectedCol!,
                                    index + 1,
                                  );
                                  setState(() {
                                    selectedRow = null;
                                    selectedCol = null;
                                  });
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
          ),
        );
      },
    );
  }
} 