import 'dart:math';

class AscendLogic {
  List<int> generate(int count, int max) {
    List<int> numbers = [];
    final rand = Random();
    while (numbers.length < count) {
      int n = rand.nextInt(max) + 1;
      if (!numbers.contains(n)) {
        numbers.add(n);
      }
    }
    return numbers;
  }
}
