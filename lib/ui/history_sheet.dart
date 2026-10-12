import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../models/calculator_mode.dart';

/// Modal bottom sheet displaying calculation history with tap-to-reuse
/// and clear actions.
class HistorySheet extends StatelessWidget {
  final List<HistoryItem> history;
  final ValueChanged<double> onSelectResult;
  final VoidCallback onClearHistory;

  const HistorySheet({
    super.key,
    required this.history,
    required this.onSelectResult,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Material(
      color: surfaceColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header Title and Clear Action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Calculation History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (history.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          onClearHistory();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.redAccent),
                        label: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),

              // History List or Empty State
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 48,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No calculations yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      // Most recent first
                      final item = history[history.length - 1 - index];
                      final val = double.tryParse(item.result);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 4.0,
                        ),
                        title: Text(
                          item.equation,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        subtitle: Text(
                          '= ${item.result}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        trailing: Chip(
                          label: Text(
                            item.mode == CalculatorMode.runningTotal
                                ? 'L→R'
                                : 'PEMDAS',
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: val != null
                            ? () {
                                onSelectResult(val);
                                Navigator.pop(context);
                              }
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
