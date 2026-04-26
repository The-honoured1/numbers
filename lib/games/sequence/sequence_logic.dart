import 'dart:math';

enum SequenceType { arithmetic, geometric, fibonacci, square, cube }

class SequenceLogic {
  final Random _rand = Random();

  SequenceQuestion generate(int streak) {
    SequenceType type = SequenceType.values[_rand.nextInt(SequenceType.values.length)];
    List<int> seq = [];
    int scale = 1 + (streak ~/ 5); // Difficulty scales up every 5 streaks
    int start = _rand.nextInt(10 * scale) + 1;

    switch (type) {
      case SequenceType.arithmetic:
        int diff = _rand.nextInt(10 * scale) + 2;
        seq = List.generate(5, (i) => start + i * diff);
        break;
      case SequenceType.geometric:
        int ratio = _rand.nextInt(3 + (streak ~/ 15)) + 2; // Ratios get bigger slowly
        seq = List.generate(5, (i) => start * pow(ratio, i).toInt());
        break;
      case SequenceType.fibonacci:
        int a = _rand.nextInt(5 * scale) + 1;
        int b = _rand.nextInt(5 * scale) + 1;
        seq = [a, b];
        for (int i = 2; i < 5; i++) seq.add(seq[i - 1] + seq[i - 2]);
        break;
      case SequenceType.square:
        int base = _rand.nextInt(5 * scale) + 1;
        seq = List.generate(5, (i) => pow(base + i, 2).toInt());
        break;
      case SequenceType.cube:
        int base = _rand.nextInt(4 + (scale ~/ 2)) + 1;
        seq = List.generate(5, (i) => pow(base + i, 3).toInt());
        break;
    }

    int missingIdx = _rand.nextInt(5);
    int answer = seq[missingIdx];
    List<String> display = seq.map((e) => e.toString()).toList();
    display[missingIdx] = '?';

    return SequenceQuestion(display.join(', '), answer, type.name.toUpperCase());
  }
}

class SequenceQuestion {
  final String text;
  final int answer;
  final String typeName;
  SequenceQuestion(this.text, this.answer, this.typeName);
}
