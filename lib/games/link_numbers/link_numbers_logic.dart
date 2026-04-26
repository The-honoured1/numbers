import 'dart:math';

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  Point move(int dx, int dy) => Point(x + dx, y + dy);
}

class LinkNumbersData {
  final int gridSize;
  final Map<Point, int> numbers; // Point -> number value
  final List<int> values; // unique values

  LinkNumbersData({
    required this.gridSize,
    required this.numbers,
    required this.values,
  });
}

class LinkNumbersLogic {
  final List<LinkNumbersData> _levels = [
    // Level 1: Standard 5x5
    LinkNumbersData(
      gridSize: 5,
      values: [1, 2, 3, 4, 5],
      numbers: {
        Point(0, 0): 1, Point(2, 0): 2, Point(4, 0): 3,
        Point(0, 4): 1, Point(2, 2): 2, Point(4, 4): 3,
        Point(0, 1): 4, Point(1, 0): 4,
        Point(3, 4): 5, Point(4, 3): 5,
      },
    ),
    // Level 2: Interlocking 5x5
    LinkNumbersData(
      gridSize: 5,
      values: [1, 2, 3, 4],
      numbers: {
        Point(0, 0): 1, Point(4, 4): 1,
        Point(0, 1): 2, Point(4, 3): 2,
        Point(0, 2): 3, Point(4, 2): 3,
        Point(0, 3): 4, Point(4, 1): 4,
      },
    ),
    // Level 3: 6x6 Snake
    LinkNumbersData(
      gridSize: 6,
      values: [1, 2, 3, 4, 5],
      numbers: {
        Point(0, 0): 1, Point(5, 0): 1,
        Point(0, 5): 2, Point(5, 5): 2,
        Point(1, 1): 3, Point(4, 1): 3,
        Point(1, 4): 4, Point(4, 4): 4,
        Point(2, 2): 5, Point(3, 3): 5,
      },
    ),
  ];

  LinkNumbersData generate(int levelIndex) {
    if (levelIndex >= 0 && levelIndex < _levels.length) {
      return _levels[levelIndex];
    }
    return _levels[Random().nextInt(_levels.length)];
  }

  int get totalLevels => _levels.length;
}
