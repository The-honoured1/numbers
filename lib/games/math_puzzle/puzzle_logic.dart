import 'dart:math';

class MathPuzzleLogic {
  final Random _rand = Random();

  Question generateQuestion(int level) {
    int opType = _rand.nextInt(3); // 0: +, 1: -, 2: *
    int a, b, result;
    String operator;

    int maxVal = 10 + (level * 5);

    if (opType == 0) {
      a = _rand.nextInt(maxVal) + 1;
      b = _rand.nextInt(maxVal) + 1;
      result = a + b;
      operator = '+';
    } else if (opType == 1) {
      result = _rand.nextInt(maxVal) + 1;
      b = _rand.nextInt(maxVal) + 1;
      a = result + b;
      operator = '-';
    } else {
      a = _rand.nextInt(sqrt(maxVal * 10).toInt()) + 1;
      b = _rand.nextInt(sqrt(maxVal * 10).toInt()) + 1;
      result = a * b;
      operator = '×';
    }

    int missingIdx = _rand.nextInt(3); // 0: a, 1: b, 2: result
    String questionText;
    int answer;

    if (missingIdx == 0) {
      questionText = '? $operator $b = $result';
      answer = a;
    } else if (missingIdx == 1) {
      questionText = '$a $operator ? = $result';
      answer = b;
    } else {
      questionText = '$a $operator $b = ?';
      answer = result;
    }

    List<int> options = [answer];
    while (options.length < 4) {
      int offset = _rand.nextInt(10) - 5;
      if (offset == 0) offset = 1;
      int wrong = answer + offset;
      if (wrong > 0 && !options.contains(wrong)) {
        options.add(wrong);
      }
    }
    options.shuffle();

    return Question(questionText, options, answer);
  }
}

class Question {
  final String text;
  final List<int> options;
  final int answer;
  Question(this.text, this.options, this.answer);
}
