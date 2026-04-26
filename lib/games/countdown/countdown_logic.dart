import 'dart:math';

class CountdownLogic {
  final Random _rand = Random();

  CountdownGame generate() {
    List<int> large = [25, 50, 75, 100];
    List<int> small = List.generate(10, (i) => i + 1)..addAll(List.generate(10, (i) => i + 1));
    
    // Pick 2 large, 4 small
    large.shuffle();
    small.shuffle();
    List<int> numbers = [large[0], large[1], small[0], small[1], small[2], small[3]];
    
    // Generate a reasonable target (100-999)
    int target = 100 + _rand.nextInt(900);
    
    return CountdownGame(target, numbers);
  }

  double? evaluate(List<String> tokens) {
    if (tokens.isEmpty) return null;
    try {
      // Basic postfix evaluation or sequential evaluation for simplicity in UI
      // For this app, I'll implement a simple sequential builder in the UI
      return null; 
    } catch (_) {
      return null;
    }
  }
}

class CountdownGame {
  final int target;
  final List<int> numbers;
  CountdownGame(this.target, this.numbers);
}
