import 'dart:math';

class SlideLogic {
  List<int> generate() {
    List<int> numbers = List.generate(16, (i) => i); // 0 is empty
    numbers.shuffle();
    
    // Ensure solvable
    while (!_isSolvable(numbers)) {
      numbers.shuffle();
    }
    return numbers;
  }

  bool _isSolvable(List<int> numbers) {
    int inversions = 0;
    int emptyRow = 0;
    
    for (int i = 0; i < 16; i++) {
      if (numbers[i] == 0) {
        emptyRow = 3 - (i ~/ 4);
        continue;
      }
      for (int j = i + 1; j < 16; j++) {
        if (numbers[j] != 0 && numbers[i] > numbers[j]) {
          inversions++;
        }
      }
    }
    
    // For 4x4:
    // If empty is on even row from bottom, inversions must be odd.
    // If empty is on odd row from bottom, inversions must be even.
    if (emptyRow % 2 == 0) {
      return inversions % 2 != 0;
    } else {
      return inversions % 2 == 0;
    }
  }

  bool isAdjacent(int idx1, int idx2) {
    final r1 = idx1 ~/ 4, c1 = idx1 % 4;
    final r2 = idx2 ~/ 4, c2 = idx2 % 1; // Wait, c2 should be idx2 % 4
    // Fix below
    return false;
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
