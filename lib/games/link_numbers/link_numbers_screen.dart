import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'package:numbers/services/ad_service.dart';
import 'link_numbers_logic.dart';

import 'package:numbers/presentation/widgets/tutorial_overlay.dart';

class LinkNumbersScreen extends StatefulWidget {
  final int initialLevel;
  const LinkNumbersScreen({super.key, this.initialLevel = 0});

  @override
  State<LinkNumbersScreen> createState() => _LinkNumbersScreenState();
}

class _LinkNumbersScreenState extends State<LinkNumbersScreen> {
  final LinkNumbersLogic _logic = LinkNumbersLogic();
  final StorageService _storage = StorageService();
  late LinkNumbersData _data;
  int _currentLevel = 0;
  
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
  final Stopwatch _sessionTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _sessionTimer.start();
    _loadLevel(widget.initialLevel);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: 'link',
        title: 'Number Link',
        description: 'Draw paths to connect the matching colored numbers. Every dot must be linked, and paths cannot intersect or overlap each other.',
        icon: Icons.link_rounded,
      );
    });
  }

  @override
  void dispose() {
    _sessionTimer.stop();
    _storage.addPlayTime('link', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _loadLevel(int index) {
    _storage.incrementPlayCount('link');
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
      _loadLevel(0);
    }
  }

  void _resetCurrentLevel() {
    setState(() {
      _paths = {};
      for (var val in _data.values) {
        _paths[val] = [];
      }
      _activeValue = null;
    });
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

    final dx = (point.x - lastPoint.x).abs();
    final dy = (point.y - lastPoint.y).abs();
    if (dx + dy != 1) return;

    bool occupied = false;
    _paths.forEach((val, p) {
      if (val != _activeValue && p.contains(point)) {
        occupied = true;
      }
    });
    if (occupied) return;

    if (path.contains(point)) {
      if (path.length > 1 && point == path[path.length - 2]) {
        setState(() {
          path.removeLast();
        });
      }
      return;
    }

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
      _storage.markDailyCompleted('link');
      _storage.saveHighScore('link_level', _currentLevel + 1);
      if ((_currentLevel + 1) % 3 == 0) AdService().showInterstitialAd();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GameResultDialog(
          title: 'Connections Made!',
          message: 'Level ${_currentLevel + 1} complete. All paths are linked without crossing.',
          buttonText: 'NEXT PUZZLE',
          color: NumbersColors.linkNumbers,
          icon: Icons.link,
          onButtonPressed: () {
            Navigator.pop(context);
            _nextLevel();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('LEVEL ${_currentLevel + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Connect identical numbers by drawing a path. Paths cannot cross.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: context.textFaint, fontSize: 13),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                              borderColor: context.border,
                              surfaceColor: context.surface,
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetCurrentLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surface,
                      foregroundColor: context.onSurface,
                      side: BorderSide(color: context.border, width: 2.5),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('RESET', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surface,
                      foregroundColor: context.onSurface,
                      side: BorderSide(color: context.border, width: 2.5),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('EXIT', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
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
  final Color borderColor;
  final Color surfaceColor;

  LinkPainter({
    required this.gridSize,
    required this.numbers,
    required this.paths,
    required this.valueColors,
    required this.borderColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    
    final linePaint = Paint()..color = borderColor.withOpacity(0.5)..strokeWidth = 1;
    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), linePaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), linePaint);
    }

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

      final headPaint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(path.last.x * cellSize + cellSize / 2, path.last.y * cellSize + cellSize / 2),
        6,
        headPaint,
      );
    });

    numbers.forEach((point, val) {
      final color = valueColors[val % valueColors.length];
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(point.x * cellSize + cellSize / 2, point.y * cellSize + cellSize / 2),
        cellSize * 0.35,
        paint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '$val',
          style: GoogleFonts.inter(
            color: surfaceColor,
            fontSize: cellSize * 0.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          point.x * cellSize + cellSize / 2 - tp.width / 2,
          point.y * cellSize + cellSize / 2 - tp.height / 2,
        ),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
