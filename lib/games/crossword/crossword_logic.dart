import 'dart:math';

class CrosswordLogic {
  final Random _rand = Random();

  CrosswordData generate(int level) {
    // 3x3 Numbers Grid
    // [n1] [o1] [n2] [o2] [n3] = [r1]
    // [o3]      [o4]      [o5]
    // [n4] [o6] [n5] [o7] [n6] = [r2]
    // [o8]      [o9]      [o10]
    // [n7] [o11][n8] [o12][n9] = [r3]
    //  =         =         =
    // [r4]      [r5]      [r6]

    late List<int> values;
    late List<int> results;
    late List<String> ops;

    int maxVal = 9 + (level * 2);

    while (true) {
        values = List.generate(9, (_) => _rand.nextInt(maxVal) + 1);
        ops = List.generate(12, (_) => ['+', '-', '×'][_rand.nextInt(3)]);
        
        // Row results
        int r1 = calculate(calculate(values[0], values[1], ops[0]), values[2], ops[1]);
        int r2 = calculate(calculate(values[3], values[4], ops[5]), values[5], ops[6]);
        int r3 = calculate(calculate(values[6], values[7], ops[10]), values[8], ops[11]);

        // Col results
        int r4 = calculate(calculate(values[0], values[3], ops[2]), values[6], ops[7]);
        int r5 = calculate(calculate(values[1], values[4], ops[3]), values[7], ops[8]);
        int r6 = calculate(calculate(values[2], values[5], ops[4]), values[8], ops[9]);

        results = [r1, r2, r3, r4, r5, r6];

        // Ensure all positive results and no mega numbers
        if (results.every((r) => r > 0 && r < 200)) {
            break;
        }
    }

    return CrosswordData(
      values: values,
      results: results,
      ops: ops,
    );
  }

  int calculate(int a, int b, String op) {
    if (op == '+') return a + b;
    if (op == '-') return a - b;
    if (op == '×') return a * b;
    return a ~/ (b == 0 ? 1 : b);
  }
}

class CrosswordData {
  final List<int> values; 
  final List<int> results; 
  final List<String> ops; 
  CrosswordData({required this.values, required this.results, required this.ops});
}
