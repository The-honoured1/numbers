import os

files = [
    'lib/presentation/screens/home_screen.dart',
    'lib/presentation/widgets/dialogs.dart',
    'lib/games/sequence/sequence_screen.dart',
    'lib/games/countdown/countdown_screen.dart',
    'lib/games/math_puzzle/puzzle_screen.dart',
]

def fix_const(file_path):
    if not os.path.exists(file_path):
        return
        
    with open(file_path, 'r') as f:
        text = f.read()

    # Match 'const ' followed by some widget and then 'context.'
    import re
    # This is a bit tricky with regex, but we can do simple replacements for common ones found in grep
    text = text.replace('const Icon(Icons.chevron_right_rounded, color: context.textFaint)', 'Icon(Icons.chevron_right_rounded, color: context.textFaint)')
    text = text.replace('const Icon(Icons.bolt_rounded, color: context.surface, size: 80)', 'Icon(Icons.bolt_rounded, color: context.surface, size: 80)')
    text = text.replace('const Divider(height: 32, color: context.border, thickness: 2.5)', 'Divider(height: 32, color: context.border, thickness: 2.5)')
    text = text.replace('const BorderSide(color: context.border', 'BorderSide(color: context.border')
    text = text.replace('const TextStyle(color: context.border)', 'TextStyle(color: context.border)')
    text = text.replace('const TextStyle(color: context.surface', 'TextStyle(color: context.surface')
    text = text.replace('const TextStyle(color: context.onSurface', 'TextStyle(color: context.onSurface')
    
    # Generic replacement for common widget patterns
    text = re.sub(r'const (Icon|BorderSide|TextStyle|Divider|BoxDecoration|BoxShadow)\(', r'\1(', text)

    with open(file_path, 'w') as f:
        f.write(text)

for file_path in files:
    fix_const(file_path)

print("Const fixes completed.")
