import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/profile_cubit.dart';
import '../../blocs/auth_cubit.dart';
import '../../blocs/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadProfile());
  }

  void _loadProfile() {
    final userId = context.read<AuthCubit>().state.userId;
    if (userId != null) {
      print('Loading profile for user: $userId');
      context.read<ProfileCubit>().loadProfile(userId);
    } else {
      print('UserId is null, waiting for auth state...');
      Future.delayed(const Duration(milliseconds: 500), _loadProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('Ошибка: ${state.error}'));
          }

          final profile = state.profile;
          if (profile == null) {
            return const Center(child: Text('Профиль не найден'));
          }

          return Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${profile.email}'),
                  Text('Никнейм: ${profile.nickname}'),
                  const SizedBox(height: 16),
                  const Text('Статистика:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Всего игр: ${profile.totalGames}'),
                  Text('Победы: ${profile.wins}'),
                  Text('Поражения: ${profile.losses}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}