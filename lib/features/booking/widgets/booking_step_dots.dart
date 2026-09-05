import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BookingStepDots extends StatelessWidget {
  const BookingStepDots({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: i == currentStep ? 28 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i <= currentStep ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
