import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/multiplayer_cubit.dart';
import '../blocs/sudoku_cubit.dart';
import '../blocs/profile_cubit.dart';
import '../repositories/multiplayer_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/sudoku_repository.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(ProfileRepository()),
        ),
        BlocProvider(
          create: (context) => MultiplayerCubit(MultiplayerRepository(SudokuRepository())),
        ),
        BlocProvider(
          create: (context) => SudokuCubit(
          SudokuRepository(),
          ProfileRepository(),
        ),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(ProfileRepository()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Судоку',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerConfig: router,
      ),
    );
  }
}