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
import '../ui/game_screen.dart';
import '../ui/pages/leaderboard_page.dart';

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      name: 'login',
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => child,
      routes: [
        GoRoute(
          name: 'home',
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          name: 'singleplayer',
          path: '/singleplayer',
          builder: (context, state) => const SinglePlayerGamePage(),
        ),
        GoRoute(
          name: 'multiplayer-search',
          path: '/multiplayer-search',
          builder: (context, state) => MultiplayerSearchPage(
            onBack: () => context.go('/home'),
          ),
        ),
        GoRoute(
          name: 'multiplayer-game',
          path: '/multiplayer-game/:gameId',
          builder: (context, state) => MultiplayerGamePage(
            gameId: state.pathParameters['gameId']!,
          ),
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) => const LeaderboardPage(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isLoginRoute = state.matchedLocation == '/';
    final isRegisterRoute = state.matchedLocation == '/register';

    if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
      return '/';
    }

    if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
      return '/home';
    }

    return null;
  },
);