import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/logic/expression_evaluator.dart';

void main() {
  group('ExpressionEvaluator - Conventional PEMDAS and Parentheses', () {
    test('Conventional Precedence: 2 + 3 × 4 = 14', () {
      final result = ExpressionEvaluator.evaluate('2 + 3 × 4');
      expect(result, 14.0);
    });

    test('Parentheses Grouping: (2 + 3) × 4 = 20', () {
      final result = ExpressionEvaluator.evaluate('(2 + 3) × 4');
      expect(result, 20.0);
    });

    test('Division and Subtraction Precedence: 20 - 10 ÷ 2 = 15', () {
      final result = ExpressionEvaluator.evaluate('20 - 10 ÷ 2');
      expect(result, 15.0);
    });

    test('Nested Parentheses: (2 + (3 × 4)) × 2 = 28', () {
      final result = ExpressionEvaluator.evaluate('(2 + (3 × 4)) × 2');
      expect(result, 28.0);
    });

    test('Decimal operands: 3.5 + 2.5 × 2 = 8.5', () {
      final result = ExpressionEvaluator.evaluate('3.5 + 2.5 × 2');
      expect(result, 8.5);
    });

    test('Unary minus: -5 + 10 = 5', () {
      final result = ExpressionEvaluator.evaluate('-5 + 10');
      expect(result, 5.0);
    });

    test('Division by zero throws FormatException', () {
      expect(
        () => ExpressionEvaluator.evaluate('10 ÷ 0'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Mismatched parentheses throws FormatException', () {
      expect(
        () => ExpressionEvaluator.evaluate('(2 + 3'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => ExpressionEvaluator.evaluate('2 + 3)'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
