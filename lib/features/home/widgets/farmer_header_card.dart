import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/user_model.dart';
import '../models/dashboard_model.dart';

class FarmerHeaderCard extends StatelessWidget {
  const FarmerHeaderCard({
    super.key,
    required this.user,
    required this.dashboard,
  });

  final UserModel user;
  final DashboardModel? dashboard;

  @override
  Widget build(BuildContext context) {
    final upcoming = dashboard?.upcomingBookings.length ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 28, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً يا ${user.name.split(' ')[0]} 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                upcoming > 0
                    ? 'عندك $upcoming موعد قادم'
                    : 'إزاي نقدر نساعد مواشيك النهاردة؟',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
