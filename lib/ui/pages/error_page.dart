import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final VoidCallback onHomePressed;

  const ErrorPage({
    Key? key,
    required this.onHomePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Произошла ошибка'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onHomePressed,
              child: const Text('Вернуться на главную'),
            ),
          ],
        ),
      ),
    );
  }
} 