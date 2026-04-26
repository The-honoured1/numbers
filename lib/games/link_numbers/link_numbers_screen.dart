import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'link_numbers_logic.dart';

class LinkNumbersScreen extends StatefulWidget {
  const LinkNumbersScreen({super.key});

  @override
  State<LinkNumbersScreen> createState() => _LinkNumbersScreenState();
}

class _LinkNumbersScreenState extends State<LinkNumbersScreen> {
  final LinkNumbersLogic _logic = LinkNumbersLogic();
  late LinkNumbersData _data;
  int _currentLevel = 0;
  
  // Maps number value to the list of points in its path
  Map<int, List<Point>> _paths = {};
  int? _activeValue;
  
  final List<Color> _valueColors = [
    NumbersColors.sudoku,
    NumbersColors.mathPuzzle,
    NumbersColors.sequence,
    NumbersColors.countdown,
    NumbersColors.linkNumbers,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadLevel(0);
  }

  void _loadLevel(int index) {
    setState(() {
      _currentLevel = index;
      _data = _logic.generate(index);
      _paths = {};
      for (var val in _data.values) {
        _paths[val] = [];
      }
      _activeValue = null;
    });
  }

  void _nextLevel() {
    if (_currentLevel < _logic.totalLevels - 1) {
      _loadLevel(_currentLevel + 1);
    } else {
        _loadLevel(0); // Loop back or show finished
    }
  }

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    final point = _getPointFromPosition(details.localPosition, constraints);
    if (point == null) return;

    final value = _data.numbers[point];
    if (value != null) {
      setState(() {
        _activeValue = value;
        _paths[value] = [point];
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_activeValue == null) return;
    
    final point = _getPointFromPosition(details.localPosition, constraints);
    if (point == null) return;

    final path = _paths[_activeValue]!;
    if (path.isEmpty) return;

    final lastPoint = path.last;
    if (point == lastPoint) return;

    // Must be adjacent (not diagonal)
    final dx = (point.x - lastPoint.x).abs();
    final dy = (point.y - lastPoint.y).abs();
    if (dx + dy != 1) return;

    // Cannot cross other paths
    bool occupied = false;
    _paths.forEach((val, p) {
      if (val != _activeValue && p.contains(point)) {
        occupied = true;
      }
    });
    if (occupied) return;

    // Cannot cross self
    if (path.contains(point)) {
      if (path.length > 1 && point == path[path.length - 2]) {
        setState(() {
          path.removeLast();
        });
      }
      return;
    }

    // Checking if we reached the other endpoint
    final endpointVal = _data.numbers[point];
    if (endpointVal != null && endpointVal != _activeValue) {
        return;
    }

    setState(() {
      path.add(point);
    });

    if (endpointVal == _activeValue) {
      _activeValue = null;
      _checkWin();
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_activeValue != null) {
        final path = _paths[_activeValue]!;
        int count = 0;
        for (var p in path) {
            if (_data.numbers[p] == _activeValue) count++;
        }
        if (count < 2) {
            setState(() {
                path.clear();
            });
        }
    }
    setState(() {
      _activeValue = null;
    });
  }

  Point? _getPointFromPosition(Offset position, BoxConstraints constraints) {
    final cellSize = constraints.maxWidth / _data.gridSize;
    final x = (position.dx / cellSize).floor();
    final y = (position.dy / cellSize).floor();
    
    if (x >= 0 && x < _data.gridSize && y >= 0 && y < _data.gridSize) {
      return Point(x, y);
    }
    return null;
  }

  void _checkWin() {
    bool allValuesLinked = true;
    for (var val in _data.values) {
        final path = _paths[val]!;
        int endPointsFound = 0;
        for (var p in path) {
            if (_data.numbers[p] == val) endPointsFound++;
        }
        if (endPointsFound < 2) allValuesLinked = false;
    }

    if (allValuesLinked) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Level Complete!'),
          content: Text('You finished Level ${_currentLevel + 1}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _nextLevel();
              },
              child: const Text('NEXT LEVEL'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('LEVEL ${_currentLevel + 1}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Connect identical numbers by drawing a path. Paths cannot cross.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: NumbersColors.textFaint, fontSize: 13),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: (d) => _handlePanStart(d, constraints),
                        onPanUpdate: (d) => _handlePanUpdate(d, constraints),
                        onPanEnd: _handlePanEnd,
                        child: CustomPaint(
                          painter: LinkPainter(
                            gridSize: _data.gridSize,
                            numbers: _data.numbers,
                            paths: _paths,
                            valueColors: _valueColors,
                          ),
                          size: Size.infinite,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 TextButton(
                    onPressed: () => _loadLevel(_currentLevel),
                    child: const Text('RESET'),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('EXIT'),
                  ),
               ],
            ),
          ),
        ],
      ),
    );
  }
}

class LinkPainter extends CustomPainter {
  final int gridSize;
  final Map<Point, int> numbers;
  final Map<int, List<Point>> paths;
  final List<Color> valueColors;

  LinkPainter({
    required this.gridSize,
    required this.numbers,
    required this.paths,
    required this.valueColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    final dotPaint = Paint()..color = NumbersColors.border..style = PaintingStyle.fill;
    
    // Draw Grid Dots
    for (int i = 0; i <= gridSize; i++) {
      for (int j = 0; j <= gridSize; j++) {
         // canvas.drawCircle(Offset(i * cellSize, j * cellSize), 1, dotPaint);
      }
    }

    // Draw Grid Lines (Subtle)
    final linePaint = Paint()..color = NumbersColors.border.withOpacity(0.5)..strokeWidth = 1;
    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), linePaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), linePaint);
    }

    // Draw Paths
    paths.forEach((val, path) {
      if (path.isEmpty) return;
      
      final color = valueColors[val % valueColors.length];
      final pathPaint = Paint()
        ..color = color
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final p = Path();
      p.moveTo(
        path[0].x * cellSize + cellSize / 2,
        path[0].y * cellSize + cellSize / 2,
      );
      for (int i = 1; i < path.length; i++) {
        p.lineTo(
          path[i].x * cellSize + cellSize / 2,
          path[i].y * cellSize + cellSize / 2,
        );
      }
      canvas.drawPath(p, pathPaint);

      // Draw active head
      final headPaint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(path.last.x * cellSize + cellSize / 2, path.last.y * cellSize + cellSize / 2),
        6,
        headPaint,
      );
    });

    // Draw Numbers
    numbers.forEach((point, val) {
      final color = valueColors[val % valueColors.length];
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      
      // Draw a circle background for the number
      canvas.drawCircle(
        Offset(point.x * cellSize + cellSize / 2, point.y * cellSize + cellSize / 2),
        cellSize * 0.35,
        paint,
      );

      // Draw number text
      TextPainter(
        text: TextSpan(
          text: '$val',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: cellSize * 0.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout()..paint(
        canvas,
        Offset(
          point.x * cellSize + cellSize / 2 - (cellSize * 0.15),
          point.y * cellSize + cellSize / 2 - (cellSize * 0.25),
        ),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
