import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/multiplayer_cubit.dart';
import 'package:go_router/go_router.dart';

class MultiplayerSearchPage extends StatelessWidget {
  final VoidCallback onBack;

  const MultiplayerSearchPage({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerCubit, MultiplayerState>(
      listener: (context, state) {
        if (state.isGameStarted) {
          context.go('/multiplayer-game/${state.gameId}');
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Поиск противника'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isSearching) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Поиск противника...'),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      context.read<MultiplayerCubit>().startSearching();
                    },
                    child: const Text('Начать поиск'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
} 