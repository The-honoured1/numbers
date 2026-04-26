import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Streak Related ---
  int get currentStreak => _prefs.getInt('current_streak') ?? 0;
  int get maxStreak => _prefs.getInt('max_streak') ?? 0;
  int get gamesPlayed => _prefs.getInt('games_played') ?? 0;
  String? get lastPlayedDate => _prefs.getString('last_played_date');

  Future<void> incrementGamesPlayed() async {
    await _prefs.setInt('games_played', gamesPlayed + 1);
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";
    final last = lastPlayedDate;

    if (last == today) return; 

    if (last != null) {
      try {
        final lastDateParts = last.split('-').map(int.parse).toList();
        final lastDate = DateTime(lastDateParts[0], lastDateParts[1], lastDateParts[2]);
        final diff = now.difference(lastDate).inDays;

        if (diff == 1) {
          await _prefs.setInt('current_streak', currentStreak + 1);
        } else {
          await _prefs.setInt('current_streak', 1);
        }
      } catch (e) {
        await _prefs.setInt('current_streak', 1);
      }
    } else {
      await _prefs.setInt('current_streak', 1);
    }

    if (currentStreak > maxStreak) {
      await _prefs.setInt('max_streak', currentStreak);
    }
    await _prefs.setString('last_played_date', today);
  }

  // --- High Scores ---
  int getHighScore(String gameId) => _prefs.getInt('hi_$gameId') ?? 0;
  
  Future<void> saveHighScore(String gameId, int score) async {
    final current = getHighScore(gameId);
    if (score > current) {
      await _prefs.setInt('hi_$gameId', score);
    }
  }

  // --- Daily Challenges ---
  bool isDailyCompleted(String gameId) {
    final today = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    return _prefs.getBool('daily_${today}_$gameId') ?? false;
  }

  Future<void> markDailyCompleted(String gameId) async {
    final today = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    await _prefs.setBool('daily_${today}_$gameId', true);
    await updateStreak();
  }
}
