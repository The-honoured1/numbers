import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // General score/streak tracking
  int getStreak() => _prefs.getInt('streak') ?? 0;
  Future<void> incrementStreak() async {
    int current = getStreak();
    await _prefs.setInt('streak', current + 1);
    await _prefs.setString('last_played', DateTime.now().toIso8601String());
  }

  // Game specific high scores
  int getHighScore(String gameId) => _prefs.getInt('high_score_$gameId') ?? 0;
  Future<void> setHighScore(String gameId, int score) async {
    int current = getHighScore(gameId);
    if (score > current) {
      await _prefs.setInt('high_score_$gameId', score);
    }
  }

  // Daily Challenge status
  bool isDailyDone(String gameId) {
    String? lastDone = _prefs.getString('daily_done_$gameId');
    if (lastDone == null) return false;
    DateTime date = DateTime.parse(lastDone);
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> markDailyDone(String gameId) async {
    await _prefs.setString('daily_done_$gameId', DateTime.now().toIso8601String());
    await incrementStreak();
  }
}
