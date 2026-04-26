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
        } else if (diff > 1) {
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
  bool isDailyCompleted(String gameId, {DateTime? date}) {
    final d = date ?? DateTime.now();
    final dateStr = "${d.year}-${d.month}-${d.day}";
    return _prefs.getBool('daily_${dateStr}_$gameId') ?? false;
  }

  bool anyDailyCompleted(DateTime date) {
    final dateStr = "${date.year}-${date.month}-${date.day}";
    // This is a bit expensive if we have many games, but for 8 it's fine
    final games = ['sudoku','2048','math_puzzle','sequence','countdown','crossword','link','minesweeper'];
    return games.any((id) => _prefs.getBool('daily_${dateStr}_$id') ?? false);
  }

  Future<void> markDailyCompleted(String gameId) async {
    final todayStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    await _prefs.setBool('daily_${todayStr}_$gameId', true);
    await updateStreak();
    await incrementGamesPlayed();
  }
}
