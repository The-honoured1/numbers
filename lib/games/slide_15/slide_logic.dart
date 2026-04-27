import 'dart:math';

class SlideLogic {

  /// Generate a solvable 15-puzzle by shuffling from the solved state.
  /// This guarantees the puzzle is always solvable.
  List<int> generate() {
    // Start from solved state
    List<int> grid = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0];
    final rand = Random();
    
    // Perform 200+ random valid moves from solved state
    // This guarantees solvability since we only make legal moves
    int emptyIdx = 15;
    for (int i = 0; i < 300; i++) {
      List<int> neighbors = _getNeighbors(emptyIdx);
      int pick = neighbors[rand.nextInt(neighbors.length)];
      grid[emptyIdx] = grid[pick];
      grid[pick] = 0;
      emptyIdx = pick;
    }
    
    return grid;
  }

  List<int> _getNeighbors(int idx) {
    int r = idx ~/ 4, c = idx % 4;
    List<int> result = [];
    if (r > 0) result.add((r - 1) * 4 + c);
    if (r < 3) result.add((r + 1) * 4 + c);
    if (c > 0) result.add(r * 4 + (c - 1));
    if (c < 3) result.add(r * 4 + (c + 1));
    return result;
  }

  bool canMove(int index, List<int> grid) {
    int emptyIdx = grid.indexOf(0);
    int r1 = index ~/ 4, c1 = index % 4;
    int r2 = emptyIdx ~/ 4, c2 = emptyIdx % 4;
    return (r1 == r2 && (c1 - c2).abs() == 1) || (c1 == c2 && (r1 - r2).abs() == 1);
  }

  bool isWin(List<int> grid) {
    for (int i = 0; i < 15; i++) {
      if (grid[i] != i + 1) return false;
    }
    return grid[15] == 0;
  }
}
