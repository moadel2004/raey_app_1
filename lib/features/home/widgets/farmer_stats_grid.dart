import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../models/dashboard_model.dart';

class FarmerStatsGrid extends StatelessWidget {
  const FarmerStatsGrid({
    super.key,
    required this.dashboard,
    required this.isLoading,
  });

  final DashboardModel? dashboard;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && dashboard == null) {
      return const SizedBox(
        height: 90,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            _StatCard(
              label: AppStrings.dashTotalAnimals,
              value: dashboard?.totalAnimals,
              icon: Icons.pets_outlined,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: AppStrings.dashTotalBookings,
              value: dashboard?.totalBookings,
              icon: Icons.assignment_outlined,
              color: Colors.blue,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: AppStrings.dashTotalFarms,
              value: dashboard?.totalFarms,
              icon: Icons.agriculture_outlined,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatCard(
              label: AppStrings.dashPendingBookings,
              value: dashboard?.pendingBookings,
              icon: Icons.hourglass_empty_outlined,
              color: AppColors.warning,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: AppStrings.dashCompletedBookings,
              value: dashboard?.completedBookings,
              icon: Icons.check_circle_outline,
              color: AppColors.success,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: AppStrings.dashCancelledBookings,
              value: dashboard?.cancelledBookings,
              icon: Icons.cancel_outlined,
              color: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int? value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value != null ? '$value' : '--',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
