import 'dart:math';

class CrosswordLogic {
  final Random _rand = Random();

  CrosswordData generate(int level) {
    late List<int> values;
    late List<int> results;
    late List<String> ops;

    // Operands must be single digits because the keypad only goes up to 9
    int maxVal = 9;

    while (true) {
      values = List.generate(9, (_) => _rand.nextInt(maxVal) + 1);
      ops = List.generate(12, (_) => ['+', '-', '×'][_rand.nextInt(3)]);

      // Row results with BODMAS
      int r1 = evaluate(values[0], ops[0], values[1], ops[1], values[2]);
      int r2 = evaluate(values[3], ops[5], values[4], ops[6], values[5]);
      int r3 = evaluate(values[6], ops[10], values[7], ops[11], values[8]);

      // Col results with BODMAS
      int r4 = evaluate(values[0], ops[2], values[3], ops[7], values[6]);
      int r5 = evaluate(values[1], ops[3], values[4], ops[8], values[7]);
      int r6 = evaluate(values[2], ops[4], values[5], ops[9], values[8]);

      results = [r1, r2, r3, r4, r5, r6];

      if (results.every((r) => r > 0 && r < 500)) {
        break;
      }
    }

    return CrosswordData(
      values: values,
      results: results,
      ops: ops,
    );
  }

  int evaluate(int a, String op1, int b, String op2, int c) {
    if (op2 == '×' && op1 != '×') {
      int sub = b * c;
      return op1 == '+' ? a + sub : a - sub;
    } else if (op1 == '×') {
      int sub = a * b;
      return op2 == '+' ? sub + c : (op2 == '-' ? sub - c : sub * c);
    } else {
      int sub = op1 == '+' ? a + b : a - b;
      return op2 == '+' ? sub + c : (op2 == '-' ? sub - c : sub * c);
    }
  }
}

class CrosswordData {
  final List<int> values;
  final List<int> results;
  final List<String> ops;
  CrosswordData({required this.values, required this.results, required this.ops});
}
