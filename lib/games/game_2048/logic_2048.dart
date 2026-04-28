import 'dart:math';

enum MoveDirection { up, down, left, right }

class Tile2048 {
  final int id;
  final int value;
  final int row;
  final int col;
  final int? fromRow;
  final int? fromCol;
  final bool isNew;
  final bool isMerged;

  Tile2048({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.fromRow,
    this.fromCol,
    this.isNew = false,
    this.isMerged = false,
  });

  Tile2048 copyWith({int? value, int? row, int? col, int? fromRow, int? fromCol, bool? isNew, bool? isMerged}) {
    return Tile2048(
      id: id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      fromRow: fromRow ?? this.fromRow,
      fromCol: fromCol ?? this.fromCol,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }
}

class Logic2048 {
  static const int size = 4;
  List<Tile2048> tiles = [];
  int score = 0;
  bool won = false;
  bool over = false;
  int _nextId = 0;

  void reset() {
    tiles = [];
    score = 0;
    won = false;
    over = false;
    _nextId = 0;
    addRandomTile();
    addRandomTile();
  }

  void addRandomTile() {
    List<Point<int>> filledPositions = tiles.map((t) => Point(t.row, t.col)).toList();
    List<Point<int>> emptyCells = [];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (!filledPositions.contains(Point(r, c))) {
          emptyCells.add(Point(r, c));
        }
      }
    }
    
    if (emptyCells.isNotEmpty) {
      Random rand = Random();
      Point<int> cell = emptyCells[rand.nextInt(emptyCells.length)];
      tiles.add(Tile2048(
        id: _nextId++,
        value: rand.nextDouble() < 0.9 ? 2 : 4,
        row: cell.x,
        col: cell.y,
        isNew: true,
      ));
    }
  }

  bool move(MoveDirection dir) {
    if (over) return false;

    // Reset state for new move
    tiles = tiles.map((t) => t.copyWith(isNew: false, isMerged: false, fromRow: t.row, fromCol: t.col)).toList();

    bool moved = false;
    int mergeScore = 0;
    List<Tile2048> nextTiles = [];
    
    List<int> r_indices = [0, 1, 2, 3];
    List<int> c_indices = [0, 1, 2, 3];

    if (dir == MoveDirection.right) c_indices = c_indices.reversed.toList();
    if (dir == MoveDirection.down) r_indices = r_indices.reversed.toList();

    // Map to track what's at each position
    Map<Point<int>, Tile2048> grid = {
      for (var t in tiles) Point(t.row, t.col): t
    };

    // To handle merges correctly, we process row by row or col by col
    if (dir == MoveDirection.left || dir == MoveDirection.right) {
      for (int r = 0; r < size; r++) {
        List<Tile2048?> row = c_indices.map((c) => grid[Point(r, c)]).toList();
        var (result, lineScore) = _processLine(row);
        mergeScore += lineScore;
        for (int i = 0; i < result.length; i++) {
          var t = result[i];
          if (t != null) {
            int targetCol = c_indices[i];
            if (t.col != targetCol || t.isMerged) moved = true;
            nextTiles.add(t.copyWith(row: r, col: targetCol));
          }
        }
      }
    } else {
      for (int c = 0; c < size; c++) {
        List<Tile2048?> col = r_indices.map((r) => grid[Point(r, c)]).toList();
        var (result, lineScore) = _processLine(col);
        mergeScore += lineScore;
        for (int i = 0; i < result.length; i++) {
          var t = result[i];
          if (t != null) {
            int targetRow = r_indices[i];
            if (t.row != targetRow || t.isMerged) moved = true;
            nextTiles.add(t.copyWith(row: targetRow, col: c));
          }
        }
      }
    }

    if (moved) {
      score += mergeScore;
      tiles = nextTiles;
      addRandomTile();
      _checkGameState();
    }

    return moved;
  }

  (List<Tile2048?>, int) _processLine(List<Tile2048?> line) {
    List<Tile2048> filtered = line.whereType<Tile2048>().toList();
    List<Tile2048?> result = List.filled(size, null);
    int lineScore = 0;
    
    int target = 0;
    for (int i = 0; i < filtered.length; i++) {
      if (i + 1 < filtered.length && filtered[i].value == filtered[i+1].value) {
        // Merge
        int newVal = filtered[i].value * 2;
        lineScore += newVal;
        if (newVal == 2048) won = true;
        
        result[target] = filtered[i].copyWith(value: newVal, isMerged: true);
        target++;
        i++;
      } else {
        result[target] = filtered[i];
        target++;
      }
    }
    return (result, lineScore);
  }

  void _checkGameState() {
    if (tiles.length < size * size) return;
    
    Map<Point<int>, int> grid = {
        for (var t in tiles) Point(t.row, t.col): t.value
    };

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        int val = grid[Point(r, c)]!;
        if (r + 1 < size && val == grid[Point(r + 1, c)]) return;
        if (c + 1 < size && val == grid[Point(r, c + 1)]) return;
      }
    }
    over = true;
  }
}
