import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';

class BookingSuccessView extends StatelessWidget {
  const BookingSuccessView({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 24),
          const Text(
            'تم إرسال طلب الحجز بنجاح!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'هيتواصل معاك الدكتور لتأكيد الموعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textMedium,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 40),
          CustomButton(label: AppStrings.bookViewOrders, onPressed: onDone),
        ],
      ),
    );
  }
}
