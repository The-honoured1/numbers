import os

def move_imports(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    import_line = "import 'package:numbers/presentation/widgets/tutorial_overlay.dart';\n"
    has_import = False
    
    out_lines = []
    for line in lines:
        if "import 'package:numbers/presentation/widgets/tutorial_overlay.dart';" in line:
            has_import = True
        else:
            out_lines.append(line)
            
    if has_import:
        out_lines.insert(0, import_line)
        
    with open(filepath, 'w') as f:
        f.writelines(out_lines)

for file in ["lib/games/sequence/sequence_screen.dart", "lib/games/countdown/countdown_screen.dart", "lib/games/sudoku/sudoku_screen.dart"]:
    move_imports(file)

def inject_tutorial(filepath, game_id, title, desc, icon):
    if not os.path.exists(filepath): return
    with open(filepath, 'r') as f:
        text = f.read()

    # ensure import exists at top
    import_str = "import 'package:numbers/presentation/widgets/tutorial_overlay.dart';\n"
    if import_str not in text:
        text = import_str + text
        
    # replace initState
    original_init = """  @override
  void initState() {
    super.initState();
    _sessionTimer.start();
    _startNewGame();
  }"""
  
    original_init_2048 = """  @override
  void initState() {
    super.initState();
    _storage.incrementPlayCount('2048');
    _sessionTimer.start();
    _startNewGame();
  }"""

    replacement = f"""  @override
  void initState() {{
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {{
      await TutorialDialog.checkAndShow(
        context: context,
        gameId: '{game_id}',
        title: '{title}',
        description: '{desc}',
        icon: {icon},
      );
      if (!mounted) return;
      _sessionTimer.start();
      setState(() => _startNewGame());
    }});
  }}"""

    replacement_2048 = f"""  @override
  void initState() {{
    super.initState();
    _storage.incrementPlayCount('2048');
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {{
      await TutorialDialog.checkAndShow(
        context: context,
        gameId: '{game_id}',
        title: '{title}',
        description: '{desc}',
        icon: {icon},
      );
      if (!mounted) return;
      _sessionTimer.start();
      setState(() => _startNewGame());
    }});
  }}"""

    if game_id == '2048':
        text = text.replace(original_init_2048, replacement_2048)
    else:
        text = text.replace(original_init, replacement)

    with open(filepath, 'w') as f:
        f.write(text)

inject_tutorial("lib/games/game_2048/screen_2048.dart", "2048", "2048", "Swipe to merge matching numbers and reach the 2048 tile!", "Icons.dashboard_rounded")
inject_tutorial("lib/games/slide_15/slide_screen.dart", "slide_15", "Slide 15", "Slide the tiles into the empty space to arrange them in numerical order from 1 to 15.", "Icons.filter_4_rounded")

print("Done")
