import 'dart:math';

class MathPuzzleLogic {
  final Random _rand = Random();

  Question generateQuestion(int level) {
    return _generateSimple(level);
  }

  Question _generateSimple(int level) {
    int opType = _rand.nextInt(3); 
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
      a = _rand.nextInt(sqrt(maxVal * 5).toInt()) + 2;
      b = _rand.nextInt(sqrt(maxVal * 5).toInt()) + 2;
      result = a * b;
      operator = '×';
    }
    return _buildQuestion(a, operator, b, result);
  }



  int _calc(int a, int b, int op) {
    if (op == 0) return a + b;
    if (op == 1) return a - b;
    return a * b;
  }

  Question _buildQuestion(int a, String op, int b, int result) {
    int missingIdx = _rand.nextInt(2); 
    String questionText = missingIdx == 0 ? '? $op $b = $result' : '$a $op ? = $result';
    int answer = missingIdx == 0 ? a : b;
    if (_rand.nextBool()) {
      questionText = '$a $op $b = ?';
      answer = result;
    }
    return _buildQuestionFromText(questionText, answer);
  }

  Question _buildQuestionFromText(String text, int answer) {
    List<int> options = [answer];
    while (options.length < 4) {
      int offset = _rand.nextInt(12) - 6;
      if (offset == 0) offset = 1;
      int wrong = answer + offset;
      if (!options.contains(wrong)) options.add(wrong);
    }
    options.shuffle();
    return Question(text, options, answer);
  }
}

class Question {
  final String text;
  final List<int> options;
  final int answer;
  Question(this.text, this.options, this.answer);
}
