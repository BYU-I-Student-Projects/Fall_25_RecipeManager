import 'package:flutter/material.dart';

class StarRatingPicker extends StatelessWidget {
  final int value; // 0..5
  final ValueChanged<int> onChanged;

  const StarRatingPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        final filled = starValue <= value;

        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          icon: Icon(filled ? Icons.star : Icons.star_border),
          onPressed: () => onChanged(starValue),
        );
      }),
    );
  }
}
