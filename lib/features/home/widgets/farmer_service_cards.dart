import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class FarmerServiceCards extends StatelessWidget {
  const FarmerServiceCards({
    super.key,
    required this.onOpenBooking,
    required this.onOpenConsultations,
  });

  final void Function(String initialType) onOpenBooking;
  final VoidCallback onOpenConsultations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ServiceCard(
          title: 'مزارعي',
          subtitle: 'عرض وإدارة مزارعك',
          icon: Icons.agriculture_outlined,
          color: Colors.green.shade50,
          onTap: () => context.go(AppRoutes.farms),
        ),
        _ServiceCard(
          title: 'اطلب كشف فوراً',
          subtitle: 'تواصل مع أقرب دكتور بيطري ليك',
          icon: Icons.medical_services_outlined,
          color: Colors.teal.shade50,
          onTap: () => onOpenBooking('FarmVisit'),
        ),
        _ServiceCard(
          title: 'استشارة أونلاين',
          subtitle: 'دردشة سريعة مع دكتور متخصص',
          icon: Icons.chat_outlined,
          color: Colors.blue.shade50,
          onTap: onOpenConsultations,
        ),
        _ServiceCard(
          title: 'الصيدلية البيطرية',
          subtitle: 'اطلب أدوية ومكملات غذائية',
          icon: Icons.local_pharmacy_outlined,
          color: Colors.orange.shade50,
        ),
        _ServiceCard(
          title: 'الدفع والاشتراك',
          subtitle: 'InstaPay أو فودافون كاش',
          icon: Icons.payment_outlined,
          color: Colors.purple.shade50,
          onTap: () => context.push(AppRoutes.payment),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Cairo',
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: onTap != null ? AppColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
