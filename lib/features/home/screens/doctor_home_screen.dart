import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/user_model.dart';
import '../../vet_profile/cubit/vet_profile_cubit.dart';
import '../../vet_profile/models/dashboard_model.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VetProfileCubit>().loadAll();
  }

  void _openProfile() {
    context.push(AppRoutes.vetProfile);
  }

  void _openAvailability() {
    context.push(AppRoutes.availability);
  }

  void _openMedicalRecords() {
    final vetId = context.read<VetProfileCubit>().cached?.profile.vetId ?? 0;
    context.push(AppRoutes.medicalRecords, extra: vetId);
  }

  void _openConsultations() {
    context.push(AppRoutes.consultations);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VetProfileCubit, VetProfileState>(
      builder: (context, state) {
        final cubit = context.read<VetProfileCubit>();
        final loaded = state is VetProfileLoaded ? state : cubit.cached;
        final dashboard = loaded?.dashboard;

        return Column(
          children: [
            _buildHeader(dashboard),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStatRow(dashboard),
                  const SizedBox(height: 25),
                  const Text(
                    'إدارة العيادة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildOption(
                    context: context,
                    title: 'بروفايلي',
                    sub: 'بياناتك ومواعيد عملك ومناطقك',
                    icon: Icons.person_outline,
                    bg: Colors.green.shade50,
                    onTap: _openProfile,
                  ),
                  _buildOption(
                    context: context,
                    title: 'جدول المواعيد',
                    sub: 'نظم مواعيد كشوفاتك اليومية',
                    icon: Icons.schedule,
                    bg: Colors.purple.shade50,
                    onTap: _openAvailability,
                  ),
                  _buildOption(
                    context: context,
                    title: 'سجل الحالات',
                    sub: 'تاريخ المرضى والتقارير السابقة',
                    icon: Icons.history,
                    bg: Colors.teal.shade50,
                    onTap: _openMedicalRecords,
                  ),
                  _buildOption(
                    context: context,
                    title: 'الاستشارات الـ Online',
                    sub: 'رد على استفسارات المزارعين',
                    icon: Icons.chat,
                    bg: Colors.red.shade50,
                    onTap: _openConsultations,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(DashboardModel? dashboard) {
    final upcoming = dashboard?.upcomingBookings ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'دكتور/ ${widget.user.name.split(' ')[0]} 🩺',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.medical_services, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            upcoming > 0 ? 'عندك $upcoming حجوزات جاية' : 'أهلاً بيك في راعى',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(DashboardModel? dashboard) {
    return Row(
      children: [
        _buildStatCard(
          'حجوزات جاية',
          '${dashboard?.upcomingBookings ?? 0}',
          Icons.pending_actions,
          Colors.blue,
        ),
        const SizedBox(width: 15),
        _buildStatCard(
          'حجوزات مكتملة',
          '${dashboard?.completedBookings ?? 0}',
          Icons.check_circle_outline,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String sub,
    required IconData icon,
    required Color bg,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          subtitle: Text(
            sub,
            style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: onTap != null ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
