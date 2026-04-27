import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:numbers/core/design_system.dart';
import 'package:numbers/presentation/widgets/dialogs.dart';
import 'package:numbers/services/storage_service.dart';
import 'crossword_logic.dart';
import 'package:numbers/presentation/widgets/tutorial_overlay.dart';
import 'package:numbers/services/ad_service.dart';

class CrosswordScreen extends StatefulWidget {
  final int initialLevel;
  const CrosswordScreen({super.key, this.initialLevel = 0});

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  final CrosswordLogic _logic = CrosswordLogic();
  final StorageService _storage = StorageService();
  late CrosswordData _data;
  List<int?> _playerValues = List.generate(9, (_) => null);
  final Set<int> _hintIndices = {};
  int? _selectedIndex;
  int _level = 0;
  int _lives = 3;
  bool _isWrong = false;
  int _revivesUsed = 0;
  final Stopwatch _sessionTimer = Stopwatch();
  
  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
    _storage.incrementPlayCount('crossword');
    _sessionTimer.start();
    _startNewLevel();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TutorialScreen.checkAndShow(
        context: context,
        gameId: 'crossword',
        title: 'Math Cross',
        description: 'Fill in the empty tiles to complete the mathematical equations stretching across the board. The numbers given at the ends must correctly equate horizontally and vertically.',
        icon: Icons.grid_goldenratio_rounded,
      );
    });
  }

  void _startNewLevel() {
    _data = _logic.generate(_level);
    _playerValues = List.generate(9, (_) => null);
    _hintIndices.clear();
    _selectedIndex = null;
    _lives = 3;
    _isWrong = false;

    // Prefill hints (less hints on higher levels)
    int hints = (4 - (_level ~/ 25)).clamp(1, 4);
    List<int> indices = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    indices.shuffle();
    for (int i = 0; i < hints; i++) {
        int idx = indices[i];
        _playerValues[idx] = _data.values[idx];
        _hintIndices.add(idx);
    }
  }

  @override
  void dispose() {
    _sessionTimer.stop();
    _storage.addPlayTime('crossword', _sessionTimer.elapsed.inSeconds);
    super.dispose();
  }

  void _onKeyPress(int value) {
    if (_selectedIndex != null && _lives > 0) {
      if (_data.values[_selectedIndex!] == value) {
        setState(() {
          _playerValues[_selectedIndex!] = value;
        });
        _checkWin();
      } else {
        _handleWrongAnswer();
      }
    }
  }

  void _handleWrongAnswer() {
    setState(() {
      _lives--;
      _isWrong = true;
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isWrong = false);
    });

    if (_lives <= 0) {
      _showGameOver();
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: 'Out of Hearts',
        message: 'You made too many mistakes. Keep practicing!',
        buttonText: 'RETRY LEVEL',
        color: NumbersColors.countdown,
        icon: Icons.favorite_border_rounded,
        onRevive: _revivesUsed < 1 ? () {
          AdService().showRewardedAd(() {
            Navigator.pop(context);
            setState(() {
              _lives = 3;
              _revivesUsed++;
            });
          });
        } : null,
        onButtonPressed: () {
          Navigator.pop(context);
          setState(() => _startNewLevel());
        },
      ),
    );
  }

  void _checkWin() {
    if (_playerValues.every((v) => v != null)) {
      final p = _playerValues;
      final o = _data.ops;
      final r = _data.results;

      bool win = true;
      
      // Horizontal Rows using the new BODMAS evaluate method
      if (_logic.evaluate(p[0]!, o[0], p[1]!, o[1], p[2]!) != r[0]) win = false;
      if (_logic.evaluate(p[3]!, o[5], p[4]!, o[6], p[5]!) != r[1]) win = false;
      if (_logic.evaluate(p[6]!, o[10], p[7]!, o[11], p[8]!) != r[2]) win = false;

      // Vertical Columns
      if (_logic.evaluate(p[0]!, o[2], p[3]!, o[7], p[6]!) != r[3]) win = false;
      if (_logic.evaluate(p[1]!, o[3], p[4]!, o[8], p[7]!) != r[4]) win = false;
      if (_logic.evaluate(p[2]!, o[4], p[5]!, o[9], p[8]!) != r[5]) win = false;

      if (win) {
        _storage.markDailyCompleted('crossword');
        _storage.saveHighScore('crossword_level', _level + 1);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GameResultDialog(
            title: 'Masterfully Solved',
            message: 'Your mathematical intuition is flawless. The grid is perfectly balanced.',
            buttonText: 'NEXT PUZZLE',
            color: NumbersColors.crossCorrect,
            icon: Icons.auto_awesome,
            onButtonPressed: () {
              Navigator.pop(context);
              if ((_level + 1) % 5 == 0) AdService().showInterstitialAd();
            },
          ),
        ).then((_) {
          setState(() {
            _level++;
            _startNewLevel();
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        title: Text('MATH CROSS', style: GoogleFonts.lora(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FILL THE GRID TO SATISFY ALL EQUATIONS',
                  style: GoogleFonts.inter(letterSpacing: 1.5, fontSize: 9, fontWeight: FontWeight.w800, color: context.textFaint),
                ),
                Row(
                  children: List.generate(3, (i) => Icon(
                    i < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: NumbersColors.coral,
                    size: 18,
                  )),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _isWrong ? NumbersColors.coral.withOpacity(0.1) : Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.border, width: 2),
                          boxShadow: [
                            BoxShadow(color: context.onSurface.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: _buildGrid(),
                      ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        _buildMainRow([0, 1, 2], [0, 1], 0),
        _buildOpConnectorRow([2, 3, 4]),
        _buildMainRow([3, 4, 5], [5, 6], 1),
        _buildOpConnectorRow([7, 8, 9]),
        _buildMainRow([6, 7, 8], [10, 11], 2),
        _buildEqualsVerticalRow(),
        _buildVerticalResultsRow(),
      ],
    );
  }

  Widget _buildMainRow(List<int> valIndices, List<int> opIndices, int resultRowIndex) {
    return Expanded(
      child: Row(
        children: [
          _buildInputCell(valIndices[0]),
          _buildOpCell(_data.ops[opIndices[0]]),
          _buildInputCell(valIndices[1]),
          _buildOpCell(_data.ops[opIndices[1]]),
          _buildInputCell(valIndices[2]),
          _buildOpCell('=', color: context.textFaint.withOpacity(0.3)),
          _buildResultCell(_data.results[resultRowIndex]),
        ],
      ),
    );
  }

  Widget _buildOpConnectorRow(List<int> opIndices) {
    return Expanded(
      child: Row(
        children: [
          _buildOpCell(_data.ops[opIndices[0]]),
          const Expanded(child: SizedBox.shrink()),
          _buildOpCell(_data.ops[opIndices[1]]),
          const Expanded(child: SizedBox.shrink()),
          _buildOpCell(_data.ops[opIndices[2]]),
          const Expanded(child: SizedBox.shrink()),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildEqualsVerticalRow() {
    return Expanded(
      child: Row(
        children: [
          _buildOpCell('='),
          const Expanded(child: SizedBox.shrink()),
          _buildOpCell('='),
          const Expanded(child: SizedBox.shrink()),
          _buildOpCell('='),
          const Expanded(child: SizedBox.shrink()),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildVerticalResultsRow() {
    return Expanded(
      child: Row(
        children: [
          _buildResultCell(_data.results[3]),
          const Expanded(child: SizedBox.shrink()),
          _buildResultCell(_data.results[4]),
          const Expanded(child: SizedBox.shrink()),
          _buildResultCell(_data.results[5]),
          const Expanded(child: SizedBox.shrink()),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildInputCell(int index) {
    bool isSelected = _selectedIndex == index;
    bool isHint = _hintIndices.contains(index);
    
    return Expanded(
      child: GestureDetector(
        onTap: isHint ? null : () => setState(() => _selectedIndex = index),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? context.surface : (isHint ? context.gridBorder.withOpacity(0.3) : context.surface),
            border: Border.all(color: isSelected ? NumbersColors.selection : context.border, width: isSelected ? 3 : 2),
            borderRadius: BorderRadius.circular(4),
            boxShadow: isSelected ? [BoxShadow(color: context.shadow, offset: const Offset(3, 3))] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            _playerValues[index]?.toString() ?? '',
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18, color: isHint ? context.textFaint : context.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildOpCell(String text, {Color? color}) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: color ?? context.textFaint)),
      ),
    );
  }

  Widget _buildResultCell(int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: NumbersColors.crossCorrect.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text('$value', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: NumbersColors.crossCorrect)),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          ...List.generate(9, (index) => _keypadButton(index + 1)),
          _keypadButton(0),
        ],
      ),
    );
  }

  Widget _keypadButton(int value) {
    return GestureDetector(
      onTap: () => _onKeyPress(value),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: context.surface,
          border: Border.all(color: context.border),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: context.onSurface.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: Text('$value', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: context.onSurface)),
      ),
    );
  }
}
