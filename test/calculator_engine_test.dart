import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/logic/calculator_engine.dart';

void main() {
  group('CalculatorEngine - Core Left-to-Right Running Total Requirements', () {
    late CalculatorEngine engine;

    setUp(() {
      engine = CalculatorEngine();
    });

    test('Initial state is 0 and enteringFirstOperand', () {
      expect(engine.displayText, '0');
      expect(engine.inputPhase, InputPhase.enteringFirstOperand);
      expect(engine.accumulator, isNull);
      expect(engine.pendingOperator, isNull);
      expect(engine.formula, '');
    });

    test('Entering digits updates displayText', () {
      engine.inputDigit('1');
      engine.inputDigit('2');
      expect(engine.displayText, '12');
      expect(engine.inputPhase, InputPhase.enteringFirstOperand);
    });

    test('Core Rule: 2 + 3 × 4 = 20 (Left-to-Right chained evaluation)', () {
      // Step 1: Input 2
      engine.inputDigit('2');
      expect(engine.displayText, '2');

      // Step 2: Input +
      engine.inputOperator('+');
      expect(engine.accumulator, 2.0);
      expect(engine.pendingOperator, '+');
      expect(engine.displayText, '2');
      expect(engine.inputPhase, InputPhase.waitingForOperand);

      // Step 3: Input 3
      engine.inputDigit('3');
      expect(engine.displayText, '3');
      expect(engine.inputPhase, InputPhase.enteringSubsequentOperand);

      // Step 4: Input × -> commits 2 + 3 = 5 as running total accumulator!
      engine.inputOperator('×');
      expect(engine.accumulator, 5.0);
      expect(engine.pendingOperator, '×');
      expect(engine.displayText, '5');
      expect(engine.inputPhase, InputPhase.waitingForOperand);

      // Step 5: Input 4
      engine.inputDigit('4');
      expect(engine.displayText, '4');
      expect(engine.inputPhase, InputPhase.enteringSubsequentOperand);

      // Step 6: Input = -> commits 5 × 4 = 20!
      final entry = engine.calculateEquals();
      expect(entry, isNotNull);
      expect(entry!['result'], '20');
      expect(engine.accumulator, 20.0);
      expect(engine.displayText, '20');
      expect(engine.inputPhase, InputPhase.showResult);
    });

    test('Trace: 12 + 3 × 4 = produces 60', () {
      // 12
      engine.inputDigit('1');
      engine.inputDigit('2');
      expect(engine.displayText, '12');

      // +
      engine.inputOperator('+');
      expect(engine.accumulator, 12.0);

      // 3
      engine.inputDigit('3');
      expect(engine.displayText, '3');

      // × -> commits 12 + 3 = 15
      engine.inputOperator('×');
      expect(engine.accumulator, 15.0);
      expect(engine.displayText, '15');

      // 4
      engine.inputDigit('4');

      // = -> 15 × 4 = 60
      engine.calculateEquals();
      expect(engine.displayText, '60');
      expect(engine.accumulator, 60.0);
    });

    test('Operator Replacement Rule: 9 + × 2 = 18', () {
      // Tap 9
      engine.inputDigit('9');
      expect(engine.displayText, '9');

      // Tap +
      engine.inputOperator('+');
      expect(engine.pendingOperator, '+');

      // Tap × immediately -> replaces + with ×!
      engine.inputOperator('×');
      expect(engine.pendingOperator, '×');
      expect(engine.accumulator, 9.0);
      expect(engine.formula, '9 ×');

      // Tap 2
      engine.inputDigit('2');
      expect(engine.displayText, '2');

      // Tap = -> 9 × 2 = 18
      engine.calculateEquals();
      expect(engine.displayText, '18');
      expect(engine.accumulator, 18.0);
    });

    test('Equals while waiting for operand leaves display and pending op unchanged: 7 + =', () {
      engine.inputDigit('7');
      engine.inputOperator('+');
      expect(engine.displayText, '7');
      expect(engine.pendingOperator, '+');
      expect(engine.inputPhase, InputPhase.waitingForOperand);

      // Tap equals
      final res = engine.calculateEquals();
      expect(res, isNull);
      expect(engine.displayText, '7');
      expect(engine.pendingOperator, '+');
      expect(engine.inputPhase, InputPhase.waitingForOperand);
    });

    test('AC clears all state: 8 + 2 × AC 4 + 1 = 5', () {
      engine.inputDigit('8');
      engine.inputOperator('+');
      engine.inputDigit('2');
      engine.inputOperator('×'); // accumulator is 10
      expect(engine.accumulator, 10.0);

      // AC reset
      engine.clearAll();
      expect(engine.accumulator, isNull);
      expect(engine.pendingOperator, isNull);
      expect(engine.displayText, '0');
      expect(engine.inputPhase, InputPhase.enteringFirstOperand);

      // Fresh calculation: 4 + 1 =
      engine.inputDigit('4');
      engine.inputOperator('+');
      engine.inputDigit('1');
      engine.calculateEquals();

      expect(engine.displayText, '5');
      expect(engine.accumulator, 5.0);
    });

    test('Digit after result starts fresh calculation', () {
      engine.inputDigit('2');
      engine.inputOperator('+');
      engine.inputDigit('3');
      engine.calculateEquals();
      expect(engine.displayText, '5');
      expect(engine.inputPhase, InputPhase.showResult);

      // Tap 4 -> should start fresh with '4', NOT '54'
      engine.inputDigit('4');
      expect(engine.displayText, '4');
      expect(engine.inputPhase, InputPhase.enteringFirstOperand);
      expect(engine.accumulator, isNull);
      expect(engine.pendingOperator, isNull);
    });

    test('Chained subtraction and division', () {
      // 10 - 2 - 3 = 5
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.inputOperator('-');
      engine.inputDigit('2');
      engine.inputOperator('-'); // commits 10 - 2 = 8
      expect(engine.displayText, '8');
      engine.inputDigit('3');
      engine.calculateEquals(); // 8 - 3 = 5
      expect(engine.displayText, '5');

      engine.clearAll();

      // 20 ÷ 4 ÷ 2 = 2.5
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputOperator('÷');
      engine.inputDigit('4');
      engine.inputOperator('÷'); // commits 20 / 4 = 5
      expect(engine.displayText, '5');
      engine.inputDigit('2');
      engine.calculateEquals(); // 5 / 2 = 2.5
      expect(engine.displayText, '2.5');
    });

    test('Division by zero triggers error and allows recovery', () {
      engine.inputDigit('5');
      engine.inputOperator('÷');
      engine.inputDigit('0');
      engine.calculateEquals();

      expect(engine.inputPhase, InputPhase.error);
      expect(engine.displayText, 'Cannot divide by 0');

      // Recover with AC
      engine.clearAll();
      expect(engine.displayText, '0');
      expect(engine.inputPhase, InputPhase.enteringFirstOperand);

      // Perform a new valid calculation
      engine.inputDigit('9');
      engine.inputOperator('+');
      engine.inputDigit('1');
      engine.calculateEquals();
      expect(engine.displayText, '10');
    });

    test('Decimal point handling and multiple decimal rejection', () {
      engine.inputDigit('3');
      engine.inputDecimal();
      engine.inputDigit('1');
      engine.inputDecimal(); // Rejected!
      engine.inputDigit('4');
      expect(engine.displayText, '3.14');

      engine.inputOperator('+');
      engine.inputDecimal(); // Leading decimal -> "0."
      engine.inputDigit('5');
      expect(engine.displayText, '0.5');

      engine.calculateEquals();
      expect(engine.displayText, '3.64');
    });

    test('Floating point precision normalization: 0.1 + 0.2 = 0.3', () {
      engine.inputDecimal();
      engine.inputDigit('1');
      engine.inputOperator('+');
      engine.inputDecimal();
      engine.inputDigit('2');
      engine.calculateEquals();
      expect(engine.displayText, '0.3');
    });

    test('Sign toggle behavior', () {
      // Toggling 0 does nothing
      engine.toggleSign();
      expect(engine.displayText, '0');

      // Toggling positive number
      engine.inputDigit('5');
      engine.toggleSign();
      expect(engine.displayText, '-5');
      engine.toggleSign();
      expect(engine.displayText, '5');

      // Chained with operation: 5 × -2 = -10
      engine.inputOperator('×');
      engine.inputDigit('2');
      engine.toggleSign();
      expect(engine.displayText, '-2');
      engine.calculateEquals();
      expect(engine.displayText, '-10');
    });

    test('Square root calculation and negative input error', () {
      engine.inputDigit('9');
      engine.squareRoot();
      expect(engine.displayText, '3');

      engine.clearAll();
      engine.inputDigit('4');
      engine.toggleSign();
      expect(engine.displayText, '-4');
      engine.squareRoot();
      expect(engine.inputPhase, InputPhase.error);
      expect(engine.displayText, 'Invalid input for √');
    });

    test('Percentage calculation', () {
      // Standalone 50% = 0.5
      engine.inputDigit('5');
      engine.inputDigit('0');
      engine.percentage();
      expect(engine.displayText, '0.5');

      engine.clearAll();

      // Operation: 200 + 10% = 20 -> 220
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('+');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 10% of 200 is 20
      expect(engine.displayText, '20');
      engine.calculateEquals();
      expect(engine.displayText, '220');
    });

    test('Backspace and Clear Entry behavior', () {
      // Backspace digits
      engine.inputDigit('1');
      engine.inputDigit('2');
      engine.inputDigit('3');
      expect(engine.displayText, '123');
      engine.backspace();
      expect(engine.displayText, '12');

      // CE preserves pending operator and accumulator
      engine.inputOperator('+');
      engine.inputDigit('9');
      engine.inputDigit('9');
      expect(engine.displayText, '99');
      engine.clearEntry();
      expect(engine.displayText, '12'); // Shows accumulator while waiting
      expect(engine.pendingOperator, '+');

      engine.inputDigit('8');
      engine.calculateEquals();
      expect(engine.displayText, '20'); // 12 + 8 = 20
    });
  });
}
