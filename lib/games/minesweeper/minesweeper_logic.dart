import 'dart:math';

enum CellState { hidden, revealed, flagged }

class MineCell {
  final int x;
  final int y;
  bool isMine;
  int neighborMines;
  CellState state;

  MineCell(this.x, this.y, {this.isMine = false, this.neighborMines = 0, this.state = CellState.hidden});
}

class MinesweeperGame {
  final int rows;
  final int cols;
  final int mineCount;
  late List<List<MineCell>> board;
  bool gameOver;
  bool gameWon;

  MinesweeperGame({required this.rows, required this.cols, required this.mineCount}) 
    : gameOver = false, gameWon = false {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(rows, (r) => List.generate(cols, (c) => MineCell(c, r)));
    
    // Plant mines
    int planted = 0;
    while (planted < mineCount) {
      int r = Random().nextInt(rows);
      int c = Random().nextInt(cols);
      if (!board[r][c].isMine) {
        board[r][c].isMine = true;
        planted++;
      }
    }

    // Calculate neighbors
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!board[r][c].isMine) {
          int count = 0;
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              int nr = r + dr;
              int nc = c + dc;
              if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc].isMine) {
                count++;
              }
            }
          }
          board[r][c].neighborMines = count;
        }
      }
    }
  }

  void reveal(int r, int c) {
    if (gameOver || gameWon || board[r][c].state != CellState.hidden) return;

    if (board[r][c].isMine) {
      board[r][c].state = CellState.revealed;
      gameOver = true;
      return;
    }

    _recursiveReveal(r, c);
    _checkWin();
  }

  void _recursiveReveal(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols || board[r][c].state == CellState.revealed) return;
    
    board[r][c].state = CellState.revealed;
    
    if (board[r][c].neighborMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          _recursiveReveal(r + dr, c + dc);
        }
      }
    }
  }

  void toggleFlag(int r, int c) {
    if (gameOver || gameWon || board[r][c].state == CellState.revealed) return;
    board[r][c].state = board[r][c].state == CellState.flagged ? CellState.hidden : CellState.flagged;
  }

  void _checkWin() {
    bool win = true;
    for (var row in board) {
      for (var cell in row) {
        if (!cell.isMine && cell.state != CellState.revealed) {
          win = false;
        }
      }
    }
    gameWon = win;
  }

  void revive(int r, int c) {
    if (!gameOver) return;
    board[r][c].state = CellState.flagged;
    gameOver = false;
  }
}
