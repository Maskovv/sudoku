import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Судоку'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/singleplayer'),
              child: const Text('Одиночная игра'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/multiplayer-search'),
              child: const Text('Сетевая игра'),
            ),
          ],
        ),
      ),
    );
  }
} 