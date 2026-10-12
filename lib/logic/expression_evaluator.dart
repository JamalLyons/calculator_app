/// Evaluates mathematical expressions using conventional precedence (PEMDAS)
/// and supports parentheses grouping.
class ExpressionEvaluator {
  /// Evaluates an infix mathematical expression string like "2 + 3 × 4" or "(2 + 3) × 4".
  /// Returns the computed [double] or throws a [FormatException] on invalid syntax or division by zero.
  static double evaluate(String expression) {
    final sanitized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(' ', '');

    if (sanitized.isEmpty) {
      throw const FormatException('Empty expression');
    }

    final tokens = _tokenize(sanitized);
    final postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  /// Tokenizes the expression string into numbers, operators, and parentheses.
  static List<String> _tokenize(String expr) {
    final tokens = <String>[];
    int i = 0;

    while (i < expr.length) {
      final ch = expr[i];

      if (_isDigit(ch) || ch == '.') {
        final buffer = StringBuffer();
        bool hasDecimal = false;
        while (i < expr.length && (_isDigit(expr[i]) || expr[i] == '.')) {
          if (expr[i] == '.') {
            if (hasDecimal) {
              throw const FormatException('Multiple decimal points in number');
            }
            hasDecimal = true;
          }
          buffer.write(expr[i]);
          i++;
        }
        tokens.add(buffer.toString());
        continue;
      }

      if (ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '(' || ch == ')') {
        // Handle unary minus: if '-' is preceded by start of string, '(', or an operator
        if (ch == '-') {
          final isUnary = tokens.isEmpty ||
              tokens.last == '(' ||
              _isOperator(tokens.last);
          if (isUnary) {
            // Read unary number if immediately followed by digit
            if (i + 1 < expr.length && (_isDigit(expr[i + 1]) || expr[i + 1] == '.')) {
              final buffer = StringBuffer('-');
              i++;
              bool hasDecimal = false;
              while (i < expr.length && (_isDigit(expr[i]) || expr[i] == '.')) {
                if (expr[i] == '.') {
                  if (hasDecimal) {
                    throw const FormatException('Multiple decimal points in number');
                  }
                  hasDecimal = true;
                }
                buffer.write(expr[i]);
                i++;
              }
              tokens.add(buffer.toString());
              continue;
            }
          }
        }

        tokens.add(ch);
        i++;
        continue;
      }

      throw FormatException('Unexpected character: $ch');
    }

    return tokens;
  }

  static bool _isDigit(String s) => RegExp(r'^[0-9]$').hasMatch(s);
  static bool _isOperator(String s) => s == '+' || s == '-' || s == '*' || s == '/';

  static int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  /// Converts infix tokens to postfix (RPN) using Dijkstra's Shunting-yard algorithm.
  static List<String> _toPostfix(List<String> tokens) {
    final output = <String>[];
    final operatorStack = <String>[];

    for (final token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
      } else if (token == '(') {
        operatorStack.add(token);
      } else if (token == ')') {
        while (operatorStack.isNotEmpty && operatorStack.last != '(') {
          output.add(operatorStack.removeLast());
        }
        if (operatorStack.isEmpty) {
          throw const FormatException('Mismatched parentheses');
        }
        operatorStack.removeLast(); // Pop '('
      } else if (_isOperator(token)) {
        while (operatorStack.isNotEmpty &&
            _isOperator(operatorStack.last) &&
            _precedence(operatorStack.last) >= _precedence(token)) {
          output.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      }
    }

    while (operatorStack.isNotEmpty) {
      final top = operatorStack.removeLast();
      if (top == '(' || top == ')') {
        throw const FormatException('Mismatched parentheses');
      }
      output.add(top);
    }

    return output;
  }

  /// Evaluates postfix (RPN) token list.
  static double _evaluatePostfix(List<String> postfix) {
    final stack = <double>[];

    for (final token in postfix) {
      final num = double.tryParse(token);
      if (num != null) {
        stack.add(num);
      } else if (_isOperator(token)) {
        if (stack.length < 2) {
          throw const FormatException('Invalid expression structure');
        }
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            if (b == 0.0) {
              throw const FormatException('Cannot divide by 0');
            }
            stack.add(a / b);
            break;
        }
      }
    }

    if (stack.length != 1) {
      throw const FormatException('Invalid expression');
    }

    return stack.single;
  }
}
