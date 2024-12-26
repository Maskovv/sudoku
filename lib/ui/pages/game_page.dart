import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/game_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    context.read<GameCubit>().startGame();
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Время: ${state.timeElapsed.inMinutes}:${(state.timeElapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 20),
                ),
                // Здесь ваша игровая сетка
              ],
            ),
          ),
        );
      },
    );
  }
}