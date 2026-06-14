import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

class LabeledFab extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const LabeledFab({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  State<LabeledFab> createState() => _LabeledFabState();
}

class _LabeledFabState extends State<LabeledFab> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 28,
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: themeAccent,
                borderRadius: BorderRadius.circular(26),
                boxShadow: _pressed
                    ? [
                        BoxShadow(
                          color: themeAccent.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: themeAccent.withValues(alpha: 0.38),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(widget.icon, size: 18, color: themeText),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.4,
                      color: themeText,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
