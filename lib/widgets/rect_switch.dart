import 'package:flutter/material.dart';

class RectSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String offLabel;
  final String onLabel;
  final bool enabled;
  final double width;
  final double height;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color knobColor;

  const RectSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.offLabel,
    required this.onLabel,
    this.enabled = true,
    this.width = 92,
    this.height = 28,
    this.activeTrackColor = const Color(0xFF66BB6A),
    this.inactiveTrackColor = const Color(0xFFB0BEC5),
    this.knobColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = value ? activeTrackColor : inactiveTrackColor;
    // 按钮（滑块）宽度为框体的一半，保持高度不变
    final knobWidth = (width / 2) - 6; // 3px 边距左右各占
    final knobHeight = height - 6;
    final knobAlignment = value ? Alignment.centerRight : Alignment.centerLeft;
    final knobMargin = const EdgeInsets.symmetric(horizontal: 3);
    final effectiveOnChanged = enabled ? onChanged : null;

    final offColorActive = const Color(0xFF0D47A1);
    final onColorActive = const Color(0xFF0D47A1);
    final labelInactive = const Color(0xFF90A4AE);

    return Opacity(
      opacity: enabled ? 1.0 : 0.7,
      child: GestureDetector(
        onTap: effectiveOnChanged == null ? null : () => effectiveOnChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 120),
              style: TextStyle(
                color: value ? labelInactive : offColorActive,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              child: Text(offLabel),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: knobAlignment,
                child: Container(
                  margin: knobMargin,
                  width: knobWidth,
                  height: knobHeight,
                  decoration: BoxDecoration(
                    color: knobColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 120),
              style: TextStyle(
                color: value ? onColorActive : labelInactive,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              child: Text(onLabel),
            ),
          ],
        ),
      ),
    );
  }
}