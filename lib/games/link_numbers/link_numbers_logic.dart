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

/// Generates puzzles by first laying down random non-crossing paths,
/// then placing endpoints. This guarantees every puzzle is solvable.
class LinkNumbersLogic {
  final Random _rand = Random();

  static const List<List<int>> _dirs = [
    [0, 1], [0, -1], [1, 0], [-1, 0]
  ];

  /// Generate a puzzle for a given level index.
  /// Level determines grid size and number of pairs.
  LinkNumbersData generate(int levelIndex) {
    int gridSize;
    int pairCount;

    if (levelIndex < 3) {
      gridSize = 5;
      pairCount = 3 + levelIndex; // 3, 4, 5 pairs
    } else if (levelIndex < 6) {
      gridSize = 6;
      pairCount = 4 + (levelIndex - 3); // 4, 5, 6 pairs
    } else {
      gridSize = 7;
      pairCount = 5 + ((levelIndex - 6) % 4); // 5-8 pairs
    }

    // Keep trying until we get a valid puzzle
    for (int attempt = 0; attempt < 100; attempt++) {
      final result = _tryGenerate(gridSize, pairCount);
      if (result != null) return result;
    }

    // Fallback: simple guaranteed puzzle
    return _fallbackPuzzle(gridSize, pairCount);
  }

  LinkNumbersData? _tryGenerate(int gridSize, int pairCount) {
    // occupied[y][x] = true if cell is used by a path
    List<List<bool>> occupied = List.generate(
      gridSize, (_) => List.filled(gridSize, false),
    );

    Map<Point, int> endpoints = {};
    List<int> values = [];

    for (int v = 1; v <= pairCount; v++) {
      // Pick a random unoccupied start cell
      Point? start = _findFreeCell(occupied, gridSize);
      if (start == null) return null;

      // Random walk from start to create a path
      int pathLen = 2 + _rand.nextInt(gridSize); // path of 2-gridSize cells
      List<Point> path = [start];
      occupied[start.y][start.x] = true;

      for (int step = 0; step < pathLen; step++) {
        List<Point> candidates = [];
        for (var d in _dirs) {
          Point next = path.last.move(d[0], d[1]);
          if (_inBounds(next, gridSize) && !occupied[next.y][next.x]) {
            candidates.add(next);
          }
        }
        if (candidates.isEmpty) break;
        Point chosen = candidates[_rand.nextInt(candidates.length)];
        path.add(chosen);
        occupied[chosen.y][chosen.x] = true;
      }

      if (path.length < 2) return null;

      endpoints[path.first] = v;
      endpoints[path.last] = v;
      values.add(v);
    }

    return LinkNumbersData(
      gridSize: gridSize,
      numbers: endpoints,
      values: values,
    );
  }

  Point? _findFreeCell(List<List<bool>> occupied, int gridSize) {
    List<Point> free = [];
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (!occupied[y][x]) free.add(Point(x, y));
      }
    }
    if (free.isEmpty) return null;
    return free[_rand.nextInt(free.length)];
  }

  bool _inBounds(Point p, int gridSize) {
    return p.x >= 0 && p.x < gridSize && p.y >= 0 && p.y < gridSize;
  }

  /// Simple fallback with guaranteed non-crossing horizontal paths
  LinkNumbersData _fallbackPuzzle(int gridSize, int pairCount) {
    Map<Point, int> numbers = {};
    List<int> values = [];
    int pairs = min(pairCount, gridSize); // max one pair per row
    for (int i = 0; i < pairs; i++) {
      int v = i + 1;
      numbers[Point(0, i)] = v;
      numbers[Point(gridSize - 1, i)] = v;
      values.add(v);
    }
    return LinkNumbersData(gridSize: gridSize, numbers: numbers, values: values);
  }

  int get totalLevels => 500;
}
