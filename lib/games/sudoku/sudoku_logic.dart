import 'dart:math';

class SudokuLogic {
  static const int size = 9;
  static const int boxSize = 3;

  List<List<int>> generatePuzzle(String difficulty) {
    List<List<int>> grid = List.generate(size, (_) => List.filled(size, 0));
    _fillGrid(grid);
    
    int cellsToRemove;
    switch (difficulty.toLowerCase()) {
      case 'easy': cellsToRemove = 30; break;
      case 'medium': cellsToRemove = 45; break;
      case 'hard': cellsToRemove = 60; break;
      default: cellsToRemove = 40;
    }

    List<List<int>> puzzle = List.generate(size, (i) => List.from(grid[i]));
    Random rand = Random();
    int removed = 0;
    while (removed < cellsToRemove) {
      int r = rand.nextInt(size);
      int c = rand.nextInt(size);
      if (puzzle[r][c] != 0) {
        puzzle[r][c] = 0;
        removed++;
      }
    }
    return puzzle;
  }

  bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col] == 0) {
          List<int> nums = List.generate(size, (i) => i + 1)..shuffle();
          for (int num in nums) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fillGrid(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < size; i++) {
      if (grid[row][i] == num) return false;
      if (grid[i][col] == num) return false;
    }
    int boxRow = (row ~/ boxSize) * boxSize;
    int boxCol = (col ~/ boxSize) * boxSize;
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        if (grid[boxRow + i][boxCol + j] == num) return false;
      }
    }
    return true;
  }

  bool isComplete(List<List<int>> grid) {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) return false;
        int val = grid[r][c];
        grid[r][c] = 0;
        if (!_isValid(grid, r, c, val)) {
          grid[r][c] = val;
          return false;
        }
        grid[r][c] = val;
      }
    }
    return true;
  }
}
