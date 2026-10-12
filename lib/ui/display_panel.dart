import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';

/// Display panel that renders the formula history line, mode pill,
/// and primary active number/result with accessibility announcements.
class DisplayPanel extends StatelessWidget {
  final String formula;
  final String displayText;
  final bool isError;
  final CalculatorMode mode;
  final VoidCallback? onClearError;

  const DisplayPanel({
    super.key,
    required this.formula,
    required this.displayText,
    required this.isError,
    required this.mode,
    this.onClearError,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0);
    final formulaColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final displayColor = isError
        ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isError
              ? (isDark ? const Color(0xFFDC2626) : const Color(0xFFEF4444))
              : (isDark ? Colors.white10 : Colors.black12),
          width: isError ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Row: Mode badge & Formula breadcrumb
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mode Indicator Chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: mode == CalculatorMode.runningTotal
                      ? (isDark ? Colors.indigo[900] : Colors.indigo[50])
                      : (isDark ? Colors.purple[900] : Colors.purple[50]),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: mode == CalculatorMode.runningTotal
                        ? (isDark ? Colors.indigo[400]! : Colors.indigo[300]!)
                        : (isDark ? Colors.purple[400]! : Colors.purple[300]!),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  mode == CalculatorMode.runningTotal ? 'L→R Mode' : 'PEMDAS Mode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: mode == CalculatorMode.runningTotal
                        ? (isDark ? Colors.indigo[200] : Colors.indigo[800])
                        : (isDark ? Colors.purple[200] : Colors.purple[800]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Formula / Expression trace
              Expanded(
                child: Text(
                  formula.isEmpty ? ' ' : formula,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: formulaColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Primary Value Display (Live Region for screen readers)
          Semantics(
            liveRegion: true,
            label: isError ? 'Error: $displayText' : 'Current value: $displayText',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                displayText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: isError ? 28.0 : 44.0,
                  fontWeight: FontWeight.w700,
                  color: displayColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          if (isError) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap AC or CE to recover',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.red[300] : Colors.red[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
