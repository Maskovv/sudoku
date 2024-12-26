import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/multiplayer_repository.dart';
import 'repositories/sudoku_repository.dart';
import 'blocs/multiplayer_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Ошибка инициализации Firebase: $e');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  final sudokuRepository = SudokuRepository();
  final multiplayerRepository = MultiplayerRepository(sudokuRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MultiplayerCubit(multiplayerRepository),
        ),
        // Другие провайдеры...
      ],
      child: const App(),
    ),
  );
}