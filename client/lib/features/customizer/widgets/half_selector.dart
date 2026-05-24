import 'package:flutter/material.dart';
import 'package:pizzaf/theme/app_theme.dart';
import 'package:shared/shared.dart';

class HalfSelector extends StatelessWidget {
  const HalfSelector({super.key, required this.selectedSide, required this.onChanged});
  final HalfSide selectedSide;
  final ValueChanged<HalfSide> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<HalfSide>(
      segments: const [
        ButtonSegment(value: HalfSide.left, icon: Icon(Icons.arrow_left), label: Text('Left')),
        ButtonSegment(value: HalfSide.right, icon: Icon(Icons.arrow_right), label: Text('Right')),
      ],
      selected: {selectedSide},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppTheme.accent;
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppTheme.textMuted;
        }),
      ),
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}
