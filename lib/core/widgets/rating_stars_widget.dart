import 'package:flutter/material.dart';

/// Read-only or interactive star rating widget.
///
/// [rating] — current value (double for display, int for input).
/// [onChanged] — if provided, stars become tappable (input mode).
/// [size] — icon size, defaults to 20.
/// [color] — filled star colour, defaults to amber.
class RatingStarsWidget extends StatelessWidget {
  const RatingStarsWidget({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 20,
    this.color = const Color(0xFFFFC107),
  });

  final double rating;
  final ValueChanged<int>? onChanged;
  final double size;
  final Color color;

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        final icon = _iconFor(starIndex);

        if (_interactive) {
          return GestureDetector(
            onTap: () => onChanged!(starIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(icon, size: size, color: color),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(icon, size: size, color: color),
        );
      }),
    );
  }

  IconData _iconFor(int starIndex) {
    if (rating >= starIndex) return Icons.star;
    if (rating >= starIndex - 0.5) return Icons.star_half;
    return Icons.star_border;
  }
}
