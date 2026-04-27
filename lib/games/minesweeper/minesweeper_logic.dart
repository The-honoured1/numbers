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
  bool _firstMove;

  MinesweeperGame({required this.rows, required this.cols, required this.mineCount}) 
    : gameOver = false, gameWon = false, _firstMove = true {
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
    if (gameOver || gameWon || board[r][c].state == CellState.flagged) return;

    if (board[r][c].state == CellState.revealed) {
      chord(r, c);
      return;
    }

    if (_firstMove) {
      _firstMove = false;
      if (board[r][c].isMine || board[r][c].neighborMines > 0) {
        _moveMineAndRecompute(r, c);
      }
    }

    if (board[r][c].isMine) {
      board[r][c].state = CellState.revealed;
      gameOver = true;
      return;
    }

    _recursiveReveal(r, c);
    _checkWin();
  }

  void chord(int r, int c) {
    if (board[r][c].state != CellState.revealed) return;
    int flags = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int nr = r + dr, nc = c + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc].state == CellState.flagged) {
          flags++;
        }
      }
    }

    if (flags == board[r][c].neighborMines) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = r + dr, nc = c + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc].state == CellState.hidden) {
            _revealInternal(nr, nc);
            if (gameOver) return; // Exit if we hit a mine
          }
        }
      }
      _checkWin();
    }
  }

  void _revealInternal(int r, int c) {
    if (board[r][c].isMine) {
      board[r][c].state = CellState.revealed;
      gameOver = true;
      return;
    }
    _recursiveReveal(r, c);
  }

  void _moveMineAndRecompute(int firstR, int firstC) {
    // Clear a 3x3 area around the first move for a better start
    List<Point<int>> removedMines = [];
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int nr = firstR + dr;
        int nc = firstC + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
          if (board[nr][nc].isMine) {
            board[nr][nc].isMine = false;
            removedMines.add(Point(nc, nr));
          }
        }
      }
    }

    // Re-plant the removed mines in other empty locations
    int needed = removedMines.length;
    while (needed > 0) {
      int r = Random().nextInt(rows);
      int c = Random().nextInt(cols);
      // Don't place in the 3x3 safe zone or where there's already a mine
      bool inSafeZone = (r - firstR).abs() <= 1 && (c - firstC).abs() <= 1;
      if (!inSafeZone && !board[r][c].isMine) {
        board[r][c].isMine = true;
        needed--;
      }
    }

    // Re-calculate all neighbors
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int count = 0;
        if (!board[r][c].isMine) {
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              int nr = r + dr;
              int nc = c + dc;
              if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc].isMine) {
                count++;
              }
            }
          }
        }
        board[r][c].neighborMines = count;
      }
    }
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
    if (gameOver) return;
    bool win = true;
    for (var row in board) {
      for (var cell in row) {
        if (!cell.isMine && cell.state != CellState.revealed) {
          win = false;
          break;
        }
      }
      if (!win) break;
    }
    gameWon = win;
  }

  void revive(int r, int c) {
    if (!gameOver) return;
    board[r][c].state = CellState.flagged;
    gameOver = false;
  }
}
