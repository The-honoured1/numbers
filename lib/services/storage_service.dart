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

  // --- All game IDs ---
  static const List<String> allGameIds = [
    'sudoku', '2048', 'math_puzzle', 'sequence', 'countdown',
    'crossword', 'link', 'minesweeper', 'slide_15', 'zen_ascend',
  ];

  // --- Game Usage Tracking ---
  int getPlayCount(String gameId) => _prefs.getInt('plays_$gameId') ?? 0;
  int getWins(String gameId) => _prefs.getInt('wins_$gameId') ?? 0;

  Future<void> incrementPlayCount(String gameId) async {
    await _prefs.setInt('plays_$gameId', getPlayCount(gameId) + 1);
    await incrementGamesPlayed();
  }

  Future<void> incrementWins(String gameId) async {
    await _prefs.setInt('wins_$gameId', getWins(gameId) + 1);
  }

  // --- Play Time Tracking (in seconds) ---
  int getPlayTime(String gameId) => _prefs.getInt('time_$gameId') ?? 0;

  Future<void> addPlayTime(String gameId, int seconds) async {
    final current = getPlayTime(gameId);
    await _prefs.setInt('time_$gameId', current + seconds);
  }

  int getTotalPlayTime() {
    return allGameIds.fold(0, (sum, id) => sum + getPlayTime(id));
  }

  /// Returns a human-readable duration string
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Favorite game is the one the user has spent the most TIME playing
  String getFavoriteGame() {
    String favorite = 'sudoku';
    int maxTime = -1;

    for (final id in allGameIds) {
      final time = getPlayTime(id);
      if (time > maxTime) {
        maxTime = time;
        favorite = id;
      }
    }

    // Prettify the ID for display
    const names = {
      'sudoku': 'SUDOKU', '2048': '2048', 'math_puzzle': 'MATH PUZZLE',
      'sequence': 'SEQUENCE', 'countdown': 'COUNTDOWN', 'crossword': 'MATH CROSS',
      'link': 'NUMBER LINK', 'minesweeper': 'MINESWEEPER', 'slide_15': 'SLIDE 15',
      'zen_ascend': 'ZEN ASCEND',
    };
    return names[favorite] ?? favorite.toUpperCase();
  }

  int getTotalWins() {
    return allGameIds.fold(0, (sum, id) => sum + getWins(id));
  }

  Future<void> markDailyCompleted(String gameId) async {
    final todayStr = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    await _prefs.setBool('daily_${todayStr}_$gameId', true);
    await updateStreak();
    await incrementWins(gameId);
  }
}
