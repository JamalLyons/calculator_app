import 'calculator_mode.dart';

/// Represents a completed calculation stored in the history log.
class HistoryItem {
  final String id;
  final String equation;
  final String result;
  final CalculatorMode mode;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.equation,
    required this.result,
    required this.mode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => '$equation = $result';
}
