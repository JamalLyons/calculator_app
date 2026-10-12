import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';
import '../models/history_item.dart';
import '../logic/calculator_engine.dart';
import '../logic/expression_evaluator.dart';
import 'display_panel.dart';
import 'keypad_grid.dart';
import 'history_sheet.dart';

/// The primary stateful calculator screen supporting running-total mode,
/// PEMDAS precedence mode, history, theme toggle, and responsive layouts.
class CalculatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const CalculatorScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Mode Selection
  CalculatorMode _currentMode = CalculatorMode.runningTotal;

  // Running Total State Machine Engine
  final CalculatorEngine _engine = CalculatorEngine();

  // Precedence Mode Expression Buffer
  String _precedenceExpression = '';
  String _precedenceResult = '0';
  bool _precedenceError = false;
  String? _precedenceErrorMessage;
  bool _precedenceShowResult = false;

  // History Log
  final List<HistoryItem> _history = [];

  // Getters for DisplayPanel
  String get _activeFormula {
    if (_currentMode == CalculatorMode.runningTotal) {
      return _engine.formula;
    }
    return _precedenceExpression;
  }

  String get _activeDisplayText {
    if (_currentMode == CalculatorMode.runningTotal) {
      return _engine.displayText;
    }
    if (_precedenceError) {
      return _precedenceErrorMessage ?? 'Error';
    }
    if (_precedenceShowResult) {
      return _precedenceResult;
    }
    return _precedenceExpression.isEmpty ? '0' : _precedenceExpression;
  }

  bool get _isError {
    if (_currentMode == CalculatorMode.runningTotal) {
      return _engine.inputPhase == InputPhase.error;
    }
    return _precedenceError;
  }

  void _onDigitTap(String digit) {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.inputDigit(digit);
      } else {
        if (_precedenceError || _precedenceShowResult) {
          _precedenceExpression = digit;
          _precedenceShowResult = false;
          _precedenceError = false;
          _precedenceErrorMessage = null;
        } else {
          _precedenceExpression += digit;
        }
      }
    });
  }

  void _onDecimalTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.inputDecimal();
      } else {
        if (_precedenceError || _precedenceShowResult) {
          _precedenceExpression = '0.';
          _precedenceShowResult = false;
          _precedenceError = false;
        } else {
          // Check if last operand in expression already contains decimal
          final parts = _precedenceExpression.split(RegExp(r'[+\-×÷*/()]'));
          final lastPart = parts.isEmpty ? '' : parts.last;
          if (!lastPart.contains('.')) {
            _precedenceExpression += lastPart.isEmpty ? '0.' : '.';
          }
        }
      }
    });
  }

  void _onOperatorTap(String op) {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.inputOperator(op);
      } else {
        if (_precedenceError) return;
        if (_precedenceShowResult) {
          _precedenceExpression = '$_precedenceResult $op ';
          _precedenceShowResult = false;
        } else if (_precedenceExpression.isEmpty) {
          _precedenceExpression = '0 $op ';
        } else {
          // Check if ending with operator, replace it
          final trimmed = _precedenceExpression.trim();
          if (trimmed.endsWith('+') ||
              trimmed.endsWith('-') ||
              trimmed.endsWith('×') ||
              trimmed.endsWith('÷')) {
            _precedenceExpression =
                '${trimmed.substring(0, trimmed.length - 1)}$op ';
          } else {
            _precedenceExpression += ' $op ';
          }
        }
      }
    });
  }

  void _onEqualsTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        final entry = _engine.calculateEquals();
        if (entry != null) {
          _history.add(HistoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            equation: entry['equation']!,
            result: entry['result']!,
            mode: CalculatorMode.runningTotal,
          ));
        }
      } else {
        if (_precedenceExpression.isEmpty || _precedenceError) return;
        try {
          final res = ExpressionEvaluator.evaluate(_precedenceExpression);
          final resStr = CalculatorEngine.formatNumber(res);
          _history.add(HistoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            equation: _precedenceExpression,
            result: resStr,
            mode: CalculatorMode.precedence,
          ));
          _precedenceResult = resStr;
          _precedenceShowResult = true;
          _precedenceError = false;
        } on FormatException catch (e) {
          _precedenceError = true;
          _precedenceErrorMessage = e.message;
        } catch (_) {
          _precedenceError = true;
          _precedenceErrorMessage = 'Calculation Error';
        }
      }
    });
  }

  void _onAllClearTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.clearAll();
      } else {
        _precedenceExpression = '';
        _precedenceResult = '0';
        _precedenceError = false;
        _precedenceErrorMessage = null;
        _precedenceShowResult = false;
      }
    });
  }

  void _onClearEntryTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.clearEntry();
      } else {
        _onAllClearTap();
      }
    });
  }

  void _onBackspaceTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.backspace();
      } else {
        if (_precedenceError || _precedenceShowResult) {
          _onAllClearTap();
        } else if (_precedenceExpression.isNotEmpty) {
          var trimmed = _precedenceExpression.trimRight();
          if (trimmed.isNotEmpty) {
            _precedenceExpression = trimmed.substring(0, trimmed.length - 1).trimRight();
          }
        }
      }
    });
  }

  void _onSignToggleTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.toggleSign();
      } else {
        if (_precedenceShowResult && !_precedenceError) {
          final val = double.tryParse(_precedenceResult);
          if (val != null && val != 0) {
            _precedenceResult = CalculatorEngine.formatNumber(-val);
            _precedenceExpression = _precedenceResult;
          }
        }
      }
    });
  }

  void _onPercentTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.percentage();
      } else {
        if (_precedenceExpression.isNotEmpty && !_precedenceError) {
          _precedenceExpression += ' ÷ 100';
          _onEqualsTap();
        }
      }
    });
  }

  void _onSquareRootTap() {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.squareRoot();
      } else {
        _onEqualsTap();
        if (!_precedenceError) {
          final val = double.tryParse(_precedenceResult) ?? 0.0;
          if (val < 0) {
            _precedenceError = true;
            _precedenceErrorMessage = 'Invalid input for √';
          } else {
            _engine.loadValue(val);
            _engine.squareRoot();
            _precedenceResult = _engine.displayText;
            _precedenceExpression = '√($val)';
          }
        }
      }
    });
  }

  void _onParenthesisTap(String paren) {
    setState(() {
      if (_currentMode == CalculatorMode.precedence) {
        if (_precedenceShowResult) {
          _precedenceExpression = paren;
          _precedenceShowResult = false;
        } else {
          _precedenceExpression += paren;
        }
      } else {
        // If user taps parenthesis in Running Total mode, prompt or switch
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Parentheses are supported in PEMDAS Mode. Switch mode in the top bar.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _onSelectHistoryResult(double value) {
    setState(() {
      if (_currentMode == CalculatorMode.runningTotal) {
        _engine.loadValue(value);
      } else {
        _precedenceResult = CalculatorEngine.formatNumber(value);
        _precedenceExpression = _precedenceResult;
        _precedenceShowResult = true;
        _precedenceError = false;
      }
    });
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => HistorySheet(
        history: _history,
        onSelectResult: _onSelectHistoryResult,
        onClearHistory: () {
          setState(() => _history.clear());
        },
      ),
    );
  }

  void _toggleCalculatorMode() {
    setState(() {
      _currentMode = _currentMode == CalculatorMode.runningTotal
          ? CalculatorMode.precedence
          : CalculatorMode.runningTotal;
      _onAllClearTap();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentMode == CalculatorMode.runningTotal
              ? 'Switched to Left-to-Right Running Total Mode (2 + 3 × 4 = 20)'
              : 'Switched to PEMDAS Precedence Mode (2 + 3 × 4 = 14)',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculator Lab',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Mode Toggle Button
          Tooltip(
            message: 'Switch between L→R and PEMDAS mode',
            child: TextButton.icon(
              onPressed: _toggleCalculatorMode,
              icon: Icon(
                _currentMode == CalculatorMode.runningTotal
                    ? Icons.trending_flat
                    : Icons.calculate_outlined,
                size: 20,
              ),
              label: Text(
                _currentMode == CalculatorMode.runningTotal ? 'L→R' : 'PEMDAS',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // History Button with badge count
          IconButton(
            tooltip: 'Calculation History',
            icon: Badge(
              isLabelVisible: _history.isNotEmpty,
              label: Text('${_history.length}'),
              child: const Icon(Icons.history),
            ),
            onPressed: _showHistoryModal,
          ),
          // Dark/Light Theme Toggle
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Light' : 'Switch to Dark',
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            if (isLandscape) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DisplayPanel(
                          formula: _activeFormula,
                          displayText: _activeDisplayText,
                          isError: _isError,
                          mode: _currentMode,
                          onClearError: _onAllClearTap,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: KeypadGrid(
                      mode: _currentMode,
                      isLandscape: true,
                      onDigitTap: _onDigitTap,
                      onDecimalTap: _onDecimalTap,
                      onOperatorTap: _onOperatorTap,
                      onEqualsTap: _onEqualsTap,
                      onAllClearTap: _onAllClearTap,
                      onClearEntryTap: _onClearEntryTap,
                      onBackspaceTap: _onBackspaceTap,
                      onSignToggleTap: _onSignToggleTap,
                      onPercentTap: _onPercentTap,
                      onSquareRootTap: _onSquareRootTap,
                      onParenthesisTap: _onParenthesisTap,
                    ),
                  ),
                ],
              );
            }

            // Portrait
            return Column(
              children: [
                DisplayPanel(
                  formula: _activeFormula,
                  displayText: _activeDisplayText,
                  isError: _isError,
                  mode: _currentMode,
                  onClearError: _onAllClearTap,
                ),
                KeypadGrid(
                  mode: _currentMode,
                  isLandscape: false,
                  onDigitTap: _onDigitTap,
                  onDecimalTap: _onDecimalTap,
                  onOperatorTap: _onOperatorTap,
                  onEqualsTap: _onEqualsTap,
                  onAllClearTap: _onAllClearTap,
                  onClearEntryTap: _onClearEntryTap,
                  onBackspaceTap: _onBackspaceTap,
                  onSignToggleTap: _onSignToggleTap,
                  onPercentTap: _onPercentTap,
                  onSquareRootTap: _onSquareRootTap,
                  onParenthesisTap: _onParenthesisTap,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
