import 'dart:math';

class CrosswordLogic {
  final Random _rand = Random();

  CrosswordData generate(int size) {
    // For 3x3 (Small): 2 horizontal equations, 2 vertical
    // For simplicity, let's build the 3x3 case perfectly
    // Structure:
    // val1 op1 val2 = res1
    // op2     op3
    // val3 op4 val4 = res2
    // =       =
    // res3    res4

    int v1, v2, v3, v4, r1, r2, r3, r4;
    String o1, o2, o3, o4;

    // To ensure integer results, we'll pick v1,v2,o1 then v3,v4,o4 etc.
    // Brute force a valid set for a few iterations
    while (true) {
      v1 = _rand.nextInt(9) + 1;
      v2 = _rand.nextInt(9) + 1;
      o1 = ['+', '-', '×'][_rand.nextInt(3)];
      r1 = _calculate(v1, v2, o1);

      v3 = _rand.nextInt(9) + 1;
      v4 = _rand.nextInt(9) + 1;
      o4 = ['+', '-', '×'][_rand.nextInt(3)];
      r2 = _calculate(v3, v4, o4);

      o2 = ['+', '-', '×'][_rand.nextInt(3)];
      r3 = _calculate(v1, v3, o2);

      o3 = ['+', '-', '×'][_rand.nextInt(3)];
      r4 = _calculate(v2, v4, o3);

      if (r1 > 0 && r2 > 0 && r3 > 0 && r4 > 0 && r1 < 100 && r2 < 100 && r3 < 100 && r4 < 100) {
        break;
      }
    }

    return CrosswordData(
      values: [v1, v2, v3, v4],
      results: [r1, r2, r3, r4],
      ops: [o1, o2, o3, o4],
    );
  }

  int _calculate(int a, int b, String op) {
    if (op == '+') return a + b;
    if (op == '-') return a - b;
    if (op == '×') return a * b;
    return a ~/ b;
  }
}

class CrosswordData {
  final List<int> values; // v1, v2, v3, v4
  final List<int> results; // r1, r2, r3, r4
  final List<String> ops; // o1, o2, o3, o4
  CrosswordData({required this.values, required this.results, required this.ops});
}
