import 'dart:math' as math;

/// Phases of calculator user input.
enum InputPhase {
  /// User is typing the initial number of an operation.
  enteringFirstOperand,

  /// An operator was pressed; waiting for the next operand to be typed.
  waitingForOperand,

  /// User is typing the second (or subsequent) number of a chained calculation.
  enteringSubsequentOperand,

  /// The '=' button was pressed and a final result is currently displayed.
  showResult,

  /// An arithmetic error (e.g. division by zero, invalid root) occurred.
  error,
}

/// The core state machine and execution engine for Left-to-Right Running Total calculations.
class CalculatorEngine {
  /// Authoritative accumulated numeric value.
  double? accumulator;

  /// Raw text input string of the currently typed operand.
  String currentOperand = '';

  /// Currently pending operator ('+', '-', '×', '÷').
  String? pendingOperator;

  /// Current input phase of the state machine.
  InputPhase inputPhase = InputPhase.enteringFirstOperand;

  /// Detailed human-readable error message when in [InputPhase.error].
  String? errorMessage;

  /// Formula breadcrumb trail displayed to the user (e.g. "12 + 3 ×").
  String formula = '';

  /// Maximum allowed digits in current operand to prevent overflow.
  static const int maxInputLength = 15;

  /// Derived display text shown as the primary value on the calculator screen.
  String get displayText {
    if (inputPhase == InputPhase.error) {
      return errorMessage ?? 'Error';
    }
    if (inputPhase == InputPhase.waitingForOperand) {
      return formatNumber(accumulator ?? 0);
    }
    if (inputPhase == InputPhase.showResult) {
      if (currentOperand.isNotEmpty) {
        return currentOperand;
      }
      return formatNumber(accumulator ?? 0);
    }
    // Entering first or subsequent operand
    if (currentOperand.isEmpty) {
      return '0';
    }
    return currentOperand;
  }

  /// Formats a numeric [double] cleanly for display:
  /// - Drops trailing '.0' for integer values (e.g. 20 instead of 20.0).
  /// - Normalizes IEEE-754 precision artifacts (e.g. 0.1 + 0.2 -> 0.3).
  /// - Strips redundant trailing zeroes after decimal.
  static String formatNumber(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? 'Infinity' : '-Infinity';

    // Check for exact integer within safe integer range
    if (value == value.roundToDouble() && value.abs() < 1e14) {
      return value.toInt().toString();
    }

    // Round to 10 decimal digits to eliminate floating point artifacts
    final fixed = value.toStringAsFixed(10);
    var trimmed = fixed;
    if (trimmed.contains('.')) {
      trimmed = trimmed.replaceAll(RegExp(r'0+$'), '');
      if (trimmed.endsWith('.')) {
        trimmed = trimmed.substring(0, trimmed.length - 1);
      }
    }
    return trimmed;
  }

  /// Appends a digit (0–9) to the current input.
  void inputDigit(String digit) {
    if (inputPhase == InputPhase.error || inputPhase == InputPhase.showResult) {
      // Starting a fresh calculation
      clearAll();
      currentOperand = digit;
      inputPhase = InputPhase.enteringFirstOperand;
      return;
    }

    if (inputPhase == InputPhase.waitingForOperand) {
      currentOperand = digit;
      inputPhase = InputPhase.enteringSubsequentOperand;
      return;
    }

    // Entering first or subsequent operand
    if (currentOperand.length >= maxInputLength) return;

    if (currentOperand == '0') {
      currentOperand = digit;
    } else if (currentOperand == '-0') {
      currentOperand = '-$digit';
    } else {
      currentOperand += digit;
    }
  }

  /// Inputs a decimal point.
  /// Prevents multiple decimal points in a single operand.
  void inputDecimal() {
    if (inputPhase == InputPhase.error || inputPhase == InputPhase.showResult) {
      clearAll();
      currentOperand = '0.';
      inputPhase = InputPhase.enteringFirstOperand;
      return;
    }

    if (inputPhase == InputPhase.waitingForOperand) {
      currentOperand = '0.';
      inputPhase = InputPhase.enteringSubsequentOperand;
      return;
    }

    if (!currentOperand.contains('.')) {
      if (currentOperand.isEmpty) {
        currentOperand = '0.';
      } else {
        currentOperand += '.';
      }
    }
  }

  /// Inputs an operator ('+', '-', '×', '÷').
  /// Applies Left-to-Right chained evaluation immediately if an operand is present.
  /// Replaces the pending operator if tapped consecutively (e.g. 9 + × 2 = 18).
  void inputOperator(String op) {
    if (inputPhase == InputPhase.error) {
      return; // Must clear error first
    }

    // Operator replacement rule:
    // When waiting for an operand, tapping another operator replaces the pending operator.
    if (inputPhase == InputPhase.waitingForOperand) {
      pendingOperator = op;
      if (accumulator != null) {
        formula = '${formatNumber(accumulator!)} $op';
      }
      return;
    }

    if (inputPhase == InputPhase.enteringFirstOperand ||
        inputPhase == InputPhase.showResult) {
      final value = double.tryParse(currentOperand) ?? accumulator ?? 0.0;
      accumulator = value;
      pendingOperator = op;
      currentOperand = '';
      formula = '${formatNumber(value)} $op';
      inputPhase = InputPhase.waitingForOperand;
      return;
    }

    if (inputPhase == InputPhase.enteringSubsequentOperand) {
      // Execute pending operation immediately (Left-to-Right running total)
      final secondOperand = double.tryParse(currentOperand);
      if (secondOperand == null) return;

      final success = _executePendingOperation(secondOperand);
      if (!success) return; // Error already set (e.g. division by zero)

      pendingOperator = op;
      currentOperand = '';
      formula = '${formatNumber(accumulator!)} $op';
      inputPhase = InputPhase.waitingForOperand;
    }
  }

  /// Evaluates the pending operation when '=' is pressed.
  /// Returns equation and result pair for history logging, or null if no calculation completed.
  Map<String, String>? calculateEquals() {
    if (inputPhase == InputPhase.error) {
      return null;
    }

    // Edge case: equals pressed while waiting for operand (e.g. 7 + =)
    // "Pressing equals while waiting for an operand leaves the display and pending operation unchanged."
    if (inputPhase == InputPhase.waitingForOperand) {
      return null;
    }

    if (inputPhase == InputPhase.enteringSubsequentOperand &&
        pendingOperator != null &&
        accumulator != null) {
      final secondOperand = double.tryParse(currentOperand);
      if (secondOperand == null) return null;

      final fullEquation =
          '$formula $currentOperand';
      final success = _executePendingOperation(secondOperand);
      if (!success) return null;

      final resultStr = formatNumber(accumulator!);
      currentOperand = resultStr;
      formula = '$fullEquation =';
      pendingOperator = null;
      inputPhase = InputPhase.showResult;

      return {
        'equation': fullEquation,
        'result': resultStr,
      };
    }

    if (inputPhase == InputPhase.enteringFirstOperand) {
      // No operator was pressed, just single number
      final val = double.tryParse(currentOperand) ?? 0.0;
      accumulator = val;
      final resultStr = formatNumber(val);
      formula = '$resultStr =';
      currentOperand = resultStr;
      inputPhase = InputPhase.showResult;
      return null;
    }

    return null;
  }

  /// Executes the arithmetic operation between [accumulator] and [secondOperand].
  bool _executePendingOperation(double secondOperand) {
    if (accumulator == null || pendingOperator == null) {
      accumulator = secondOperand;
      return true;
    }

    double result = 0.0;
    switch (pendingOperator) {
      case '+':
        result = accumulator! + secondOperand;
        break;
      case '-':
        result = accumulator! - secondOperand;
        break;
      case '×':
      case '*':
        result = accumulator! * secondOperand;
        break;
      case '÷':
      case '/':
        if (secondOperand == 0.0) {
          _triggerError('Cannot divide by 0');
          return false;
        }
        result = accumulator! / secondOperand;
        break;
      default:
        result = secondOperand;
    }

    if (result.isNaN || result.isInfinite) {
      _triggerError('Calculation Overflow');
      return false;
    }

    accumulator = result;
    return true;
  }

  /// Sets error state and user-friendly error message.
  void _triggerError(String message) {
    inputPhase = InputPhase.error;
    errorMessage = message;
    formula = '';
    accumulator = null;
    currentOperand = '';
    pendingOperator = null;
  }

  /// All Clear (AC): Resets display and all pending state.
  void clearAll() {
    accumulator = null;
    currentOperand = '';
    pendingOperator = null;
    inputPhase = InputPhase.enteringFirstOperand;
    errorMessage = null;
    formula = '';
  }

  /// Clear Entry (CE): Clears only the current operand being entered.
  void clearEntry() {
    if (inputPhase == InputPhase.error) {
      clearAll();
      return;
    }
    if (inputPhase == InputPhase.showResult) {
      clearAll();
      return;
    }
    currentOperand = '';
    if (inputPhase == InputPhase.enteringSubsequentOperand) {
      inputPhase = InputPhase.waitingForOperand;
    }
  }

  /// Backspace: deletes the last character entered.
  void backspace() {
    if (inputPhase == InputPhase.error || inputPhase == InputPhase.showResult) {
      clearAll();
      return;
    }
    if (inputPhase == InputPhase.waitingForOperand) {
      return;
    }
    if (currentOperand.isNotEmpty) {
      currentOperand = currentOperand.substring(0, currentOperand.length - 1);
      if (currentOperand.isEmpty || currentOperand == '-') {
        currentOperand = '';
        if (inputPhase == InputPhase.enteringSubsequentOperand) {
          inputPhase = InputPhase.waitingForOperand;
        }
      }
    }
  }

  /// Toggles the sign (positive / negative) of current value.
  void toggleSign() {
    if (inputPhase == InputPhase.error) return;

    if (inputPhase == InputPhase.showResult ||
        inputPhase == InputPhase.waitingForOperand) {
      if (accumulator != null && accumulator != 0.0) {
        accumulator = -accumulator!;
        currentOperand = formatNumber(accumulator!);
        inputPhase = InputPhase.enteringFirstOperand;
      }
      return;
    }

    if (currentOperand.isEmpty || currentOperand == '0') {
      return;
    }

    if (currentOperand.startsWith('-')) {
      currentOperand = currentOperand.substring(1);
    } else {
      currentOperand = '-$currentOperand';
    }
  }

  /// Percentage calculation (%):
  /// - If standalone: divides current value by 100.
  /// - If chained after an operator: computes percentage relative to accumulator (e.g. 200 + 10% = 20).
  void percentage() {
    if (inputPhase == InputPhase.error) return;

    if (inputPhase == InputPhase.waitingForOperand && accumulator != null) {
      final pct = accumulator! / 100.0;
      currentOperand = formatNumber(pct);
      inputPhase = InputPhase.enteringSubsequentOperand;
      return;
    }

    final val = double.tryParse(currentOperand) ?? accumulator ?? 0.0;
    double result = 0.0;

    if (accumulator != null && pendingOperator != null) {
      // Percentage of accumulator: accumulator * (val / 100)
      result = accumulator! * (val / 100.0);
    } else {
      // Standalone percent: val / 100
      result = val / 100.0;
    }

    currentOperand = formatNumber(result);
    if (inputPhase == InputPhase.showResult) {
      accumulator = result;
    } else if (inputPhase == InputPhase.enteringFirstOperand) {
      accumulator = result;
    }
  }

  /// Calculates square root (√) of current value.
  void squareRoot() {
    if (inputPhase == InputPhase.error) return;

    final val = double.tryParse(currentOperand) ?? accumulator ?? 0.0;
    if (val < 0) {
      _triggerError('Invalid input for √');
      return;
    }

    final root = math.sqrt(val);
    final formatted = formatNumber(root);
    currentOperand = formatted;

    if (inputPhase == InputPhase.showResult) {
      accumulator = root;
      formula = '√($val) =';
    } else if (inputPhase == InputPhase.waitingForOperand) {
      inputPhase = InputPhase.enteringSubsequentOperand;
    }
  }

  /// Loads a result directly from calculation history.
  void loadValue(double value) {
    clearAll();
    accumulator = value;
    currentOperand = formatNumber(value);
    inputPhase = InputPhase.showResult;
  }
}
