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
  final Random _rand = Random();

  static const List<List<int>> _dirs = [
    [0, 1], [0, -1], [1, 0], [-1, 0]
  ];

  LinkNumbersData generate(int levelIndex) {
    int gridSize;
    int pairCount;

    if (levelIndex < 10) {
      gridSize = 5;
      pairCount = 5; 
    } else if (levelIndex < 25) {
      gridSize = 6;
      pairCount = 6;
    } else if (levelIndex < 50) {
      gridSize = 7;
      pairCount = 7;
    } else if (levelIndex < 100) {
      gridSize = 8;
      pairCount = 8;
    } else {
      gridSize = 9;
      pairCount = 10;
    }

    // Attempt to generate a puzzle that fills the maximum amount of the board
    // A 100% full board is the standard for Flow-style puzzles with unique solutions.
    for (int attempt = 0; attempt < 500; attempt++) {
      final result = _tryGenerateFullBoard(gridSize, pairCount);
      if (result != null) return result;
    }

    return _fallbackPuzzle(gridSize, pairCount);
  }

  LinkNumbersData? _tryGenerateFullBoard(int gridSize, int pairCount) {
    List<List<int?>> grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
    Map<Point, int> endpoints = {};
    List<int> values = [];

    int currentId = 1;
    
    while (currentId <= pairCount) {
      Point? start = _findFreeCell(grid, gridSize);
      if (start == null) break;

      List<Point> path = [start];
      grid[start.y][start.x] = currentId;

      // Try to grow the path
      bool growing = true;
      while (growing) {
        var shDirs = List.from(_dirs)..shuffle();
        growing = false;
        for (var d in shDirs) {
          Point next = path.last.move(d[0], d[1]);
          if (_isValid(next, gridSize, grid)) {
            path.add(next);
            grid[next.y][next.x] = currentId;
            growing = true;
            break;
          }
        }
      }

      if (path.length >= 2) {
        endpoints[path.first] = currentId;
        endpoints[path.last] = currentId;
        values.add(currentId);
        currentId++;
      } else {
        // Path too short, backtrack
        grid[start.y][start.x] = null;
        // If we can't place a path, this attempt is likely flawed
        break;
      }
    }

    // If board is not sufficiently full, reject.
    // Near 100% coverage makes for the best puzzles.
    int occupied = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell != null) occupied++;
      }
    }

    // We want near-perfect or perfect coverage to ensure uniqueness
    double coverage = occupied / (gridSize * gridSize);
    if (coverage < 0.95 || values.length < pairCount - 1) {
       return null;
    }

    return LinkNumbersData(
      gridSize: gridSize,
      numbers: endpoints,
      values: values,
    );
  }

  Point? _findFreeCell(List<List<int?>> grid, int gridSize) {
    List<Point> free = [];
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (grid[y][x] == null) free.add(Point(x, y));
      }
    }
    if (free.isEmpty) return null;
    return free[_rand.nextInt(free.length)];
  }

  bool _isValid(Point p, int gridSize, List<List<int?>> grid) {
    if (p.x < 0 || p.x >= gridSize || p.y < 0 || p.y >= gridSize) return false;
    if (grid[p.y][p.x] != null) return false;
    
    // Check neighbors to avoid "trapping" areas early
    // This is a simple heuristic to keep paths snaking
    int freeNeighbors = 0;
    for (var d in _dirs) {
      Point n = p.move(d[0], d[1]);
      if (n.x >= 0 && n.x < gridSize && n.y >= 0 && n.y < gridSize && grid[n.y][n.x] == null) {
        freeNeighbors++;
      }
    }
    return true;
  }

  LinkNumbersData _fallbackPuzzle(int gridSize, int pairCount) {
    Map<Point, int> numbers = {};
    List<int> values = [];
    int pairs = min(pairCount, gridSize);
    for (int i = 0; i < pairs; i++) {
        numbers[Point(0, i)] = i + 1;
        numbers[Point(gridSize - 1, i)] = i + 1;
        values.add(i + 1);
    }
    return LinkNumbersData(gridSize: gridSize, numbers: numbers, values: values);
  }

  int get totalLevels => 500;
}
