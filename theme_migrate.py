import os

files = [
    'lib/presentation/screens/home_screen.dart',
    'lib/presentation/widgets/dialogs.dart',
    'lib/presentation/widgets/game_card.dart',
    'lib/games/math_puzzle/puzzle_screen.dart',
    'lib/games/crossword/crossword_screen.dart',
    'lib/games/minesweeper/minesweeper_screen.dart',
    'lib/games/ascend/ascend_screen.dart',
    'lib/games/game_2048/screen_2048.dart',
    'lib/games/link_numbers/link_numbers_screen.dart',
    'lib/games/sudoku/sudoku_screen.dart',
    'lib/games/countdown/countdown_screen.dart',
    'lib/games/slide_15/slide_screen.dart',
    'lib/games/sequence/sequence_screen.dart',
]

for file_path in files:
    if not os.path.exists(file_path):
        continue
        
    with open(file_path, 'r') as f:
        text = f.read()

    text = text.replace('NumbersColors.backgroundOffWhite', 'context.surface')
    text = text.replace('NumbersColors.textBody', 'context.onSurface')
    text = text.replace('NumbersColors.border', 'context.border')
    text = text.replace('NumbersColors.cardShadow', 'context.shadow')
    text = text.replace('NumbersColors.textFaint', 'context.textFaint')

    # Fix invalid const arrays caused by dynamic context variables
    text = text.replace('const [\n            BoxShadow(\n              color: context.shadow', '[\n            BoxShadow(\n              color: context.shadow')
    text = text.replace('const [\n          BoxShadow(\n            color: context.shadow', '[\n          BoxShadow(\n            color: context.shadow')
    text = text.replace('const [\n                  BoxShadow(color: context.shadow', '[\n                  BoxShadow(color: context.shadow')
    text = text.replace('const [\n                  BoxShadow(\n                    color: context.shadow', '[\n                  BoxShadow(\n                    color: context.shadow')
    text = text.replace('const IconThemeData(color: context.onSurface)', 'IconThemeData(color: context.onSurface)')
    text = text.replace('const Icon(Icons.check, color: context.onSurface', 'Icon(Icons.check, color: context.onSurface')
    text = text.replace('const Icon(Icons.blur_on, color: context.onSurface', 'Icon(Icons.blur_on, color: context.onSurface')
    text = text.replace('const Icon(Icons.notifications_none_rounded, color: context.onSurface', 'Icon(Icons.notifications_none_rounded, color: context.onSurface')
    text = text.replace('const Icon(Icons.check_circle_rounded, color: context.onSurface', 'Icon(Icons.check_circle_rounded, color: context.onSurface')
    text = text.replace('const Icon(Icons.check_rounded, color: context.onSurface', 'Icon(Icons.check_rounded, color: context.onSurface')
    text = text.replace('const BoxDecoration(shape: BoxShape.circle, color: context.surface)', 'BoxDecoration(shape: BoxShape.circle, color: context.surface)')

    with open(file_path, 'w') as f:
        f.write(text)

print("Migration completed successfully.")
