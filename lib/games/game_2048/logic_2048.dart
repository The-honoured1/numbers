import 'dart:math';

enum MoveDirection { up, down, left, right }

class Logic2048 {
  static const int size = 4;
  List<List<int>> grid = List.generate(size, (_) => List.filled(size, 0));
  int score = 0;
  bool won = false;
  bool over = false;

  void reset() {
    grid = List.generate(size, (_) => List.filled(size, 0));
    score = 0;
    won = false;
    over = false;
    addRandomTile();
    addRandomTile();
  }

  void addRandomTile() {
    List<Point<int>> emptyCells = [];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) emptyCells.add(Point(r, c));
      }
    }
    if (emptyCells.isNotEmpty) {
      Random rand = Random();
      Point<int> cell = emptyCells[rand.nextInt(emptyCells.length)];
      grid[cell.x][cell.y] = rand.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool move(MoveDirection dir) {
    bool moved = false;
    List<List<int>> newGrid = List.generate(size, (r) => List.from(grid[r]));

    if (dir == MoveDirection.left || dir == MoveDirection.right) {
      for (int r = 0; r < size; r++) {
        List<int> row = newGrid[r];
        if (dir == MoveDirection.right) row = row.reversed.toList();
        List<int> merged = _merge(row);
        if (dir == MoveDirection.right) merged = merged.reversed.toList();
        if (!_listsEqual(newGrid[r], merged)) {
          newGrid[r] = merged;
          moved = true;
        }
      }
    } else {
      for (int c = 0; c < size; c++) {
        List<int> col = [newGrid[0][c], newGrid[1][c], newGrid[2][c], newGrid[3][c]];
        if (dir == MoveDirection.down) col = col.reversed.toList();
        List<int> merged = _merge(col);
        if (dir == MoveDirection.down) merged = merged.reversed.toList();
        for (int r = 0; r < size; r++) {
          if (newGrid[r][c] != merged[r]) {
            newGrid[r][c] = merged[r];
            moved = true;
          }
        }
      }
    }

    if (moved) {
      grid = newGrid;
      addRandomTile();
      _checkGameState();
    }
    return moved;
  }

  List<int> _merge(List<int> line) {
    List<int> nonZero = line.where((x) => x != 0).toList();
    List<int> result = [];
    for (int i = 0; i < nonZero.length; i++) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        int newVal = nonZero[i] * 2;
        result.add(newVal);
        score += newVal;
        if (newVal == 2048) won = true;
        i++;
      } else {
        result.add(nonZero[i]);
      }
    }
    while (result.length < size) {
      result.add(0);
    }
    return result;
  }

  bool _listsEqual(List<int> a, List<int> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _checkGameState() {
    bool canMove = false;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) return;
        if (r + 1 < size && grid[r][c] == grid[r + 1][c]) return;
        if (c + 1 < size && grid[r][c] == grid[r][c + 1]) return;
      }
    }
    over = true;
  }

  void revive() {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 2 || grid[r][c] == 4) {
          grid[r][c] = 0;
        }
      }
    }
    over = false;
  }
}
