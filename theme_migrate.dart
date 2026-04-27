import 'dart:io';

void main() {
  final files = [
    'lib/presentation/screens/home_screen.dart',
    'lib/presentation/widgets/dialogs.dart',
    'lib/games/math_puzzle/puzzle_screen.dart',
    'lib/games/crossword/crossword_screen.dart',
    'lib/games/minesweeper/minesweeper_screen.dart',
    'lib/games/ascend/ascend_screen.dart',
    'lib/games/game_2048/screen_2048.dart',
    'lib/games/link_numbers/link_numbers_screen.dart',
    'lib/games/sudo/sudoku_screen.dart',
    'lib/games/countdown/countdown_screen.dart',
    'lib/games/slide_15/slide_screen.dart',
    'lib/games/sequence/sequence_screen.dart',
  ];

  for (var filePath in files) {
    if (!File(filePath).existsSync()) continue;
    var text = File(filePath).readAsStringSync();

    text = text.replaceAll('NumbersColors.backgroundOffWhite', 'context.surface');
    text = text.replaceAll('NumbersColors.textBody', 'context.onSurface');
    text = text.replaceAll('NumbersColors.border', 'context.border');
    text = text.replaceAll('NumbersColors.cardShadow', 'context.shadow');
    text = text.replaceAll('NumbersColors.textFaint', 'context.textFaint');
    
    // Fix invalid const arrays caused by dynamic context variables
    text = text.replaceAll('const [\n            BoxShadow(\n              color: context.shadow', '[\n            BoxShadow(\n              color: context.shadow');
    text = text.replaceAll('const [\n          BoxShadow(\n            color: context.shadow', '[\n          BoxShadow(\n            color: context.shadow');
    text = text.replaceAll('const [\n                  BoxShadow(color: context.shadow', '[\n                  BoxShadow(color: context.shadow');
    text = text.replaceAll('const IconThemeData(color: context.onSurface)', 'IconThemeData(color: context.onSurface)');
    text = text.replaceAll('const Icon(Icons.check, color: context.onSurface', 'Icon(Icons.check, color: context.onSurface');
    text = text.replaceAll('const Icon(Icons.blur_on, color: context.onSurface', 'Icon(Icons.blur_on, color: context.onSurface');
    text = text.replaceAll('const Icon(Icons.notifications_none_rounded, color: context.onSurface', 'Icon(Icons.notifications_none_rounded, color: context.onSurface');
    text = text.replaceAll('const Icon(Icons.check_circle_rounded, color: context.onSurface', 'Icon(Icons.check_circle_rounded, color: context.onSurface');
    text = text.replaceAll('const Icon(Icons.check_rounded, color: context.onSurface', 'Icon(Icons.check_rounded, color: context.onSurface');
    text = text.replaceAll('const BoxDecoration(shape: BoxShape.circle, color: context.surface)', 'BoxDecoration(shape: BoxShape.circle, color: context.surface)');

    File(filePath).writeAsStringSync(text);
  }
}
