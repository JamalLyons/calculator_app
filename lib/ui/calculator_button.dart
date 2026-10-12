import 'package:flutter/material.dart';

/// An accessible, animated calculator button with tactile scale feedback,
/// ink ripple, and TalkBack semantic announcements.
class CalculatorButton extends StatefulWidget {
  final String label;
  final String? semanticLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final int flex;
  final double fontSize;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.semanticLabel,
    this.onLongPress,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.flex = 1,
    this.fontSize = 24.0,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.92);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSemantic = widget.semanticLabel ?? widget.label;

    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Semantics(
          label: effectiveSemantic,
          button: true,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 48.0,
                ),
                child: Material(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16.0),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onTap,
                    onLongPress: widget.onLongPress,
                    splashColor: widget.textColor.withValues(alpha: 0.15),
                    highlightColor: widget.textColor.withValues(alpha: 0.08),
                    child: Center(
                      child: widget.icon != null
                          ? Icon(
                              widget.icon,
                              color: widget.textColor,
                              size: 26,
                            )
                          : Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.w600,
                                color: widget.textColor,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
