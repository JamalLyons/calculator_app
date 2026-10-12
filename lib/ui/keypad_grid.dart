import 'package:flutter/material.dart';
import 'calculator_button.dart';
import 'theme_data.dart';
import '../models/calculator_mode.dart';

/// Keypad grid rendering appropriate button layout for Portrait and Landscape modes.
class KeypadGrid extends StatelessWidget {
  final CalculatorMode mode;
  final bool isLandscape;
  final ValueChanged<String> onDigitTap;
  final VoidCallback onDecimalTap;
  final ValueChanged<String> onOperatorTap;
  final VoidCallback onEqualsTap;
  final VoidCallback onAllClearTap;
  final VoidCallback onClearEntryTap;
  final VoidCallback onBackspaceTap;
  final VoidCallback onSignToggleTap;
  final VoidCallback onPercentTap;
  final VoidCallback onSquareRootTap;
  final ValueChanged<String> onParenthesisTap;

  const KeypadGrid({
    super.key,
    required this.mode,
    required this.isLandscape,
    required this.onDigitTap,
    required this.onDecimalTap,
    required this.onOperatorTap,
    required this.onEqualsTap,
    required this.onAllClearTap,
    required this.onClearEntryTap,
    required this.onBackspaceTap,
    required this.onSignToggleTap,
    required this.onPercentTap,
    required this.onSquareRootTap,
    required this.onParenthesisTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final numBg = isDark ? AppThemes.darkNumberBtn : AppThemes.lightNumberBtn;
    final numText = isDark ? AppThemes.darkNumberText : AppThemes.lightNumberText;

    final opBg = isDark ? AppThemes.darkOperatorBtn : AppThemes.lightOperatorBtn;
    final opText = isDark ? AppThemes.darkOperatorText : AppThemes.lightOperatorText;

    final actionBg = isDark ? AppThemes.darkActionBtn : AppThemes.lightActionBtn;
    final actionText = isDark ? AppThemes.darkActionText : AppThemes.lightActionText;

    final equalsBg = isDark ? AppThemes.darkEqualsBtn : AppThemes.lightEqualsBtn;
    final equalsText = isDark ? AppThemes.darkEqualsText : AppThemes.lightEqualsText;

    final specialBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final specialText = isDark ? Colors.tealAccent : Colors.teal[800]!;

    if (isLandscape) {
      // 5 Rows x 6 Columns for Landscape mode
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Column(
            children: [
              // Row 1
              Expanded(
                child: Row(
                  children: [
                    CalculatorButton(
                      label: '(',
                      semanticLabel: 'Open parenthesis',
                      onTap: () => onParenthesisTap('('),
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: ')',
                      semanticLabel: 'Close parenthesis',
                      onTap: () => onParenthesisTap(')'),
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: 'AC',
                      semanticLabel: 'All clear',
                      onTap: onAllClearTap,
                      backgroundColor: actionBg,
                      textColor: actionText,
                    ),
                    CalculatorButton(
                      label: 'CE',
                      semanticLabel: 'Clear entry',
                      onTap: onClearEntryTap,
                      backgroundColor: actionBg,
                      textColor: actionText,
                    ),
                    CalculatorButton(
                      label: '⌫',
                      semanticLabel: 'Backspace, long press for all clear',
                      onTap: onBackspaceTap,
                      onLongPress: onAllClearTap,
                      backgroundColor: actionBg,
                      textColor: actionText,
                    ),
                    CalculatorButton(
                      label: '÷',
                      semanticLabel: 'Divide',
                      onTap: () => onOperatorTap('÷'),
                      backgroundColor: opBg,
                      textColor: opText,
                    ),
                  ],
                ),
              ),
              // Row 2
              Expanded(
                child: Row(
                  children: [
                    CalculatorButton(
                      label: '√',
                      semanticLabel: 'Square root',
                      onTap: onSquareRootTap,
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: '%',
                      semanticLabel: 'Percent',
                      onTap: onPercentTap,
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: '7',
                      semanticLabel: 'Digit 7',
                      onTap: () => onDigitTap('7'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '8',
                      semanticLabel: 'Digit 8',
                      onTap: () => onDigitTap('8'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '9',
                      semanticLabel: 'Digit 9',
                      onTap: () => onDigitTap('9'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '×',
                      semanticLabel: 'Multiply',
                      onTap: () => onOperatorTap('×'),
                      backgroundColor: opBg,
                      textColor: opText,
                    ),
                  ],
                ),
              ),
              // Row 3
              Expanded(
                child: Row(
                  children: [
                    CalculatorButton(
                      label: '±',
                      semanticLabel: 'Toggle positive or negative',
                      onTap: onSignToggleTap,
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: 'x²',
                      semanticLabel: 'Square',
                      onTap: () {
                        // Square: Multiply by self
                        onOperatorTap('×');
                        onEqualsTap();
                      },
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: '4',
                      semanticLabel: 'Digit 4',
                      onTap: () => onDigitTap('4'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '5',
                      semanticLabel: 'Digit 5',
                      onTap: () => onDigitTap('5'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '6',
                      semanticLabel: 'Digit 6',
                      onTap: () => onDigitTap('6'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '-',
                      semanticLabel: 'Subtract',
                      onTap: () => onOperatorTap('-'),
                      backgroundColor: opBg,
                      textColor: opText,
                    ),
                  ],
                ),
              ),
              // Row 4 & 5 Combined
              Expanded(
                child: Row(
                  children: [
                    CalculatorButton(
                      label: '00',
                      semanticLabel: 'Double zero',
                      onTap: () {
                        onDigitTap('0');
                        onDigitTap('0');
                      },
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: '.',
                      semanticLabel: 'Decimal point',
                      onTap: onDecimalTap,
                      backgroundColor: specialBg,
                      textColor: specialText,
                    ),
                    CalculatorButton(
                      label: '1',
                      semanticLabel: 'Digit 1',
                      onTap: () => onDigitTap('1'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '2',
                      semanticLabel: 'Digit 2',
                      onTap: () => onDigitTap('2'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '3',
                      semanticLabel: 'Digit 3',
                      onTap: () => onDigitTap('3'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '+',
                      semanticLabel: 'Add',
                      onTap: () => onOperatorTap('+'),
                      backgroundColor: opBg,
                      textColor: opText,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    CalculatorButton(
                      label: '0',
                      semanticLabel: 'Digit 0',
                      flex: 4,
                      onTap: () => onDigitTap('0'),
                      backgroundColor: numBg,
                      textColor: numText,
                    ),
                    CalculatorButton(
                      label: '=',
                      semanticLabel: 'Equals',
                      flex: 2,
                      onTap: onEqualsTap,
                      backgroundColor: equalsBg,
                      textColor: equalsText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Portrait Layout
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          children: [
            // Advanced Operation Quick Bar
            Row(
              children: [
                if (mode == CalculatorMode.precedence) ...[
                  CalculatorButton(
                    label: '(',
                    semanticLabel: 'Open parenthesis',
                    onTap: () => onParenthesisTap('('),
                    backgroundColor: specialBg,
                    textColor: specialText,
                    fontSize: 18,
                  ),
                  CalculatorButton(
                    label: ')',
                    semanticLabel: 'Close parenthesis',
                    onTap: () => onParenthesisTap(')'),
                    backgroundColor: specialBg,
                    textColor: specialText,
                    fontSize: 18,
                  ),
                ],
                CalculatorButton(
                  label: '√',
                  semanticLabel: 'Square root',
                  onTap: onSquareRootTap,
                  backgroundColor: specialBg,
                  textColor: specialText,
                  fontSize: 18,
                ),
                CalculatorButton(
                  label: '%',
                  semanticLabel: 'Percent',
                  onTap: onPercentTap,
                  backgroundColor: specialBg,
                  textColor: specialText,
                  fontSize: 18,
                ),
                CalculatorButton(
                  label: '±',
                  semanticLabel: 'Toggle positive or negative',
                  onTap: onSignToggleTap,
                  backgroundColor: specialBg,
                  textColor: specialText,
                  fontSize: 18,
                ),
              ],
            ),

            // Row 1: AC, CE, ⌫, ÷
            Expanded(
              child: Row(
                children: [
                  CalculatorButton(
                    label: 'AC',
                    semanticLabel: 'All clear',
                    onTap: onAllClearTap,
                    backgroundColor: actionBg,
                    textColor: actionText,
                  ),
                  CalculatorButton(
                    label: 'CE',
                    semanticLabel: 'Clear entry',
                    onTap: onClearEntryTap,
                    backgroundColor: actionBg,
                    textColor: actionText,
                  ),
                  CalculatorButton(
                    label: '⌫',
                    semanticLabel: 'Backspace, long press for all clear',
                    onTap: onBackspaceTap,
                    onLongPress: onAllClearTap,
                    backgroundColor: actionBg,
                    textColor: actionText,
                  ),
                  CalculatorButton(
                    label: '÷',
                    semanticLabel: 'Divide',
                    onTap: () => onOperatorTap('÷'),
                    backgroundColor: opBg,
                    textColor: opText,
                  ),
                ],
              ),
            ),

            // Row 2: 7, 8, 9, ×
            Expanded(
              child: Row(
                children: [
                  CalculatorButton(
                    label: '7',
                    semanticLabel: 'Digit 7',
                    onTap: () => onDigitTap('7'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '8',
                    semanticLabel: 'Digit 8',
                    onTap: () => onDigitTap('8'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '9',
                    semanticLabel: 'Digit 9',
                    onTap: () => onDigitTap('9'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '×',
                    semanticLabel: 'Multiply',
                    onTap: () => onOperatorTap('×'),
                    backgroundColor: opBg,
                    textColor: opText,
                  ),
                ],
              ),
            ),

            // Row 3: 4, 5, 6, -
            Expanded(
              child: Row(
                children: [
                  CalculatorButton(
                    label: '4',
                    semanticLabel: 'Digit 4',
                    onTap: () => onDigitTap('4'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '5',
                    semanticLabel: 'Digit 5',
                    onTap: () => onDigitTap('5'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '6',
                    semanticLabel: 'Digit 6',
                    onTap: () => onDigitTap('6'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '-',
                    semanticLabel: 'Subtract',
                    onTap: () => onOperatorTap('-'),
                    backgroundColor: opBg,
                    textColor: opText,
                  ),
                ],
              ),
            ),

            // Row 4: 1, 2, 3, +
            Expanded(
              child: Row(
                children: [
                  CalculatorButton(
                    label: '1',
                    semanticLabel: 'Digit 1',
                    onTap: () => onDigitTap('1'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '2',
                    semanticLabel: 'Digit 2',
                    onTap: () => onDigitTap('2'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '3',
                    semanticLabel: 'Digit 3',
                    onTap: () => onDigitTap('3'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '+',
                    semanticLabel: 'Add',
                    onTap: () => onOperatorTap('+'),
                    backgroundColor: opBg,
                    textColor: opText,
                  ),
                ],
              ),
            ),

            // Row 5: 0, ., =
            Expanded(
              child: Row(
                children: [
                  CalculatorButton(
                    label: '0',
                    semanticLabel: 'Digit 0',
                    flex: 2,
                    onTap: () => onDigitTap('0'),
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '.',
                    semanticLabel: 'Decimal point',
                    onTap: onDecimalTap,
                    backgroundColor: numBg,
                    textColor: numText,
                  ),
                  CalculatorButton(
                    label: '=',
                    semanticLabel: 'Equals',
                    onTap: onEqualsTap,
                    backgroundColor: equalsBg,
                    textColor: equalsText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
