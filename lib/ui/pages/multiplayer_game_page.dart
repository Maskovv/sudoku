import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/multiplayer_cubit.dart';
import '../../blocs/sudoku_cubit.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class MultiplayerGamePage extends StatefulWidget {
  final String gameId;

  const MultiplayerGamePage({required this.gameId, super.key});

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel(); // Отменяем предыдущий таймер, если он есть
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<MultiplayerCubit>().leaveGame();
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Игра #${widget.gameId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<MultiplayerCubit>().leaveGame();
              context.go('/home');
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Время: ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            // Остальной UI игры
          ],
        ),
      ),
    );
  }
}