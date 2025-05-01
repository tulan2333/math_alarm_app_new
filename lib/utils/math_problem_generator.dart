import 'dart:math';

class MathProblem {
  final int left;
  final int right;
  final String operator;
  final int result;

  MathProblem({
    required this.left,
    required this.right,
    required this.operator,
    required this.result,
  });
}

class MathProblemGenerator {
  static final Random _random = Random();

  static MathProblem generateProblem(int difficulty) {
    int left;
    int right;
    String operator;
    int result;

    switch (difficulty) {
      case 1: // Fácil
        left = _random.nextInt(10) + 1;
        right = _random.nextInt(10) + 1;
        operator = '+';
        result = left + right;
        break;
      case 2: // Medio
        left = _random.nextInt(20) + 1;
        right = _random.nextInt(20) + 1;
        operator = _random.nextBool() ? '+' : '-';
        result = operator == '+' ? left + right : left - right;
        break;
      case 3: // Difícil
        left = _random.nextInt(12) + 1;
        right = _random.nextInt(12) + 1;
        operator = '*';
        result = left * right;
        break;
      default:
        left = _random.nextInt(10) + 1;
        right = _random.nextInt(10) + 1;
        operator = '+';
        result = left + right;
    }

    return MathProblem(
      left: left,
      right: right,
      operator: operator,
      result: result,
    );
  }

  static List<int> generateOptions(int correctResult) {
    final List<int> options = [correctResult];
    
    while (options.length < 4) {
      int offset = _random.nextInt(5) + 1;
      int newOption = _random.nextBool() 
          ? correctResult + offset 
          : correctResult - offset;
      
      if (!options.contains(newOption)) {
        options.add(newOption);
      }
    }
    
    options.shuffle();
    return options;
  }
}
