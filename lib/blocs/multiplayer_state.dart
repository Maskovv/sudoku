class MultiplayerState {
  final bool isSearching;
  final bool isGameStarted;
  final String? gameId;
  final String? error;

  MultiplayerState({
    this.isSearching = false,
    this.isGameStarted = false,
    this.gameId,
    this.error,
  });

  MultiplayerState copyWith({
    bool? isSearching,
    bool? isGameStarted,
    String? gameId,
    String? error,
  }) {
    return MultiplayerState(
      isSearching: isSearching ?? this.isSearching,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      gameId: gameId ?? this.gameId,
      error: error,
    );
  }
} 