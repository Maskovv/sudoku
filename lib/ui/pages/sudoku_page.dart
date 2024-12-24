import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SudokuPage extends StatelessWidget {
  const SudokuPage({super.key});

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
      body: Column(
        children: [
          // Таймер
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '20:00',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          // Уровни сложности
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Легкий'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Средний'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Сложный'),
              ),
            ],
          ),
          // Сетка судоку
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      '',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}