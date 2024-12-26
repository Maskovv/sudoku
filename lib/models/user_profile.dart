class UserProfile {
  final String uid;
  final String email;
  final String nickname;
  final int totalGames;
  final int wins;
  final int losses;

  UserProfile({
    required this.uid,
    required this.email,
    required this.nickname,
    this.totalGames = 0,
    this.wins = 0,
    this.losses = 0,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    print('UserProfile.fromMap: $map');
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nickname: map['nickname'] ?? '',
      totalGames: map['totalGames'] ?? 0,
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'totalGames': totalGames,
      'wins': wins,
      'losses': losses,
    };
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, nickname: $nickname, totalGames: $totalGames, wins: $wins, losses: $losses)';
  }
} 