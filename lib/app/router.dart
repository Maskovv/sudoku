import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/profile_page.dart';
import '../ui/pages/single_player_game_page.dart';
import '../ui/pages/multiplayer_search_page.dart';
import '../ui/pages/multiplayer_game_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/register_page.dart';
import '../ui/pages/sudoku_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/sudoku',
      builder: (context, state) => const SudokuPage(),
    ),
  ],
);