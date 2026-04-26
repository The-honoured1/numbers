import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system.dart';
import '../widgets/win_dialog.dart';
import 'logic_2048.dart';

class Screen2048 extends StatefulWidget {
  const Screen2048({super.key});

  @override
  State<Screen2048> createState() => _Screen2048State();
}

class _Screen2048State extends State<Screen2048> {
  final Logic2048 _logic = Logic2048();

  @override
  void initState() {
    super.initState();
    _logic.reset();
  }

  void _handleSwipe(MoveDirection dir) {
    setState(() {
      _logic.move(dir);
    });
    if (_logic.over) _showGameOver();
    if (_logic.won) _showWinDialog();
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinDialog(
        title: 'Legendary!',
        message: 'You reached the 2048 tile. A master of the grid!',
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onNext: () {
          Navigator.pop(context);
          setState(() => _logic.reset());
        },
      ),
    );
  }

  void _showGameOver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: ${_logic.score}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _logic.reset());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFFEEE4DA);
      case 4: return const Color(0xFFEDE0C8);
      case 8: return const Color(0xFFF2B179);
      case 16: return const Color(0xFFF59563);
      case 32: return const Color(0xFFF67C5F);
      case 64: return const Color(0xFFF65E3B);
      case 128: return const Color(0xFFEDCF72);
      case 256: return const Color(0xFFEDCC61);
      case 512: return const Color(0xFFEDC850);
      case 1024: return const Color(0xFFEDC53F);
      case 2048: return const Color(0xFFEDC22E);
      default: return const Color(0xFFCDC1B4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => setState(() => _logic.reset()), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SCORE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text('${_logic.score}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (_logic.won)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                    child: const Text('YOU WIN!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < -100) _handleSwipe(MoveDirection.up);
                  if (details.primaryVelocity! > 100) _handleSwipe(MoveDirection.down);
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < -100) _handleSwipe(MoveDirection.left);
                  if (details.primaryVelocity! > 100) _handleSwipe(MoveDirection.right);
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBADA0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        int r = index ~/ 4;
                        int c = index % 4;
                        int val = _logic.grid[r][c];
                        return Container(
                          decoration: BoxDecoration(
                            color: _getTileColor(val),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            val == 0 ? '' : '$val',
                            style: TextStyle(
                              fontSize: val > 100 ? 20 : 28,
                              fontWeight: FontWeight.bold,
                              color: val <= 4 ? const Color(0xFF776E65) : Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Swipe to move tiles and merge same numbers!', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
