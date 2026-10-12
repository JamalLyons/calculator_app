/// Defines the calculator evaluation mode.
enum CalculatorMode {
  /// Left-to-right running total mode (core requirement).
  /// Every operator commits the previous pending operation immediately.
  /// Example: 2 + 3 × 4 = (2 + 3) × 4 = 20.
  runningTotal,

  /// Conventional precedence mode (PEMDAS with parentheses).
  /// Respects multiplication/division precedence over addition/subtraction.
  /// Example: 2 + 3 × 4 = 2 + (3 × 4) = 14.
  precedence,
}
