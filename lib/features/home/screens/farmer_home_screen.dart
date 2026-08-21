import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/user_model.dart';
import '../../booking/cubit/booking_cubit.dart';
import '../../booking/screens/booking_flow_screen.dart';
import '../../consultations/cubit/consultations_cubit.dart';
import '../../consultations/screens/consultations_list_screen.dart';
import '../../payment/screens/payment_screen.dart';
import '../cubit/home_cubit.dart';
import '../models/dashboard_model.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadDashboard();
  }

  Future<void> _openBookingFlow(String initialType) async {
    final switchToOrders = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<BookingCubit>(),
          child: BookingFlowScreen(initialType: initialType),
        ),
      ),
    );
    if (switchToOrders == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<HomeCubit>().setTab(1);
      });
    }
  }

  void _openConsultationsList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ConsultationsCubit>(),
          child: const ConsultationsListScreen(),
        ),
      ),
    );
  }

  // ── Status colour ──────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed': return AppColors.success;
      case 'Pending':   return AppColors.warning;
      case 'Cancelled': return AppColors.error;
      default:          return AppColors.textLight;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final loaded    = state is HomeLoaded ? state : null;
        final dashboard = loaded?.dashboard;
        final isLoading = loaded?.isDashboardLoading ?? false;
        final error     = loaded?.dashboardError;

        return Column(
          children: [
            _buildHeader(dashboard),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<HomeCubit>().loadDashboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row
                      _buildStatsRow(dashboard, isLoading),
                      const SizedBox(height: 24),

                      // Service cards
                      const Text(
                        AppStrings.dashServices,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildServiceCards(),
                      const SizedBox(height: 28),

                      // Upcoming bookings
                      const Text(
                        AppStrings.dashUpcoming,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildUpcomingSection(dashboard, isLoading, error),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(DashboardModel? dashboard) {
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
                'أهلاً يا ${widget.user.name.split(' ')[0]} 👋',
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

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(DashboardModel? dashboard, bool isLoading) {
    if (isLoading && dashboard == null) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              AppStrings.dashTotalAnimals,
              dashboard?.totalAnimals,
              Icons.pets_outlined,
              Colors.green,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              AppStrings.dashTotalBookings,
              dashboard?.totalBookings,
              Icons.assignment_outlined,
              Colors.blue,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              AppStrings.dashTotalFarms,
              dashboard?.totalFarms,
              Icons.agriculture_outlined,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatCard(
              AppStrings.dashPendingBookings,
              dashboard?.pendingBookings,
              Icons.hourglass_empty_outlined,
              AppColors.warning,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              AppStrings.dashCompletedBookings,
              dashboard?.completedBookings,
              Icons.check_circle_outline,
              AppColors.success,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              AppStrings.dashCancelledBookings,
              dashboard?.cancelledBookings,
              Icons.cancel_outlined,
              AppColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int? value, IconData icon, Color color) {
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

  // ── Service cards ──────────────────────────────────────────────────────────

  Widget _buildServiceCards() {
    return Column(
      children: [
        _buildServiceCard(
          title: 'مزارعي',
          subtitle: 'عرض وإدارة مزارعك',
          icon: Icons.agriculture_outlined,
          color: Colors.green.shade50,
          onTap: () => context.go(AppRoutes.farms),
        ),
        _buildServiceCard(
          title: 'اطلب كشف فوراً',
          subtitle: 'تواصل مع أقرب دكتور بيطري ليك',
          icon: Icons.medical_services_outlined,
          color: Colors.teal.shade50,
          onTap: () => _openBookingFlow('FarmVisit'),
        ),
        _buildServiceCard(
          title: 'استشارة أونلاين',
          subtitle: 'دردشة سريعة مع دكتور متخصص',
          icon: Icons.chat_outlined,
          color: Colors.blue.shade50,
          onTap: () => _openConsultationsList(),
        ),
        _buildServiceCard(
          title: 'الصيدلية البيطرية',
          subtitle: 'اطلب أدوية ومكملات غذائية',
          icon: Icons.local_pharmacy_outlined,
          color: Colors.orange.shade50,
        ),
        _buildServiceCard(
          title: 'الدفع والاشتراك',
          subtitle: 'InstaPay أو فودافون كاش',
          icon: Icons.payment_outlined,
          color: Colors.purple.shade50,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const PaymentScreen(),
          )),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
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

  // ── Upcoming bookings ──────────────────────────────────────────────────────

  Widget _buildUpcomingSection(
    DashboardModel? dashboard,
    bool isLoading,
    String? error,
  ) {
    // First-load spinner
    if (isLoading && dashboard == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Error with retry (only if no cached dashboard)
    if (error != null && dashboard == null) {
      return _buildErrorBanner(error);
    }

    final bookings = (dashboard?.upcomingBookings ?? [])
        .where((b) => b.status == 'Pending' || b.status == 'Confirmed')
        .toList();

    if (bookings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text(
              AppStrings.dashNoUpcoming,
              style: TextStyle(
                color: AppColors.textMedium,
                fontFamily: 'Cairo',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: bookings
          .map((b) => _buildBookingItem(b))
          .toList(),
    );
  }

  Widget _buildBookingItem(BookingSummaryModel b) {
    final d = b.scheduledAt;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final timeStr =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final color = _statusColor(b.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.veterinarianName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (b.farmName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      b.farmName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '$dateStr  $timeStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                b.statusAr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontFamily: 'Cairo',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.read<HomeCubit>().loadDashboard(),
            icon: const Icon(Icons.refresh),
            label: const Text('حاول تاني'),
          ),
        ],
      ),
    );
  }
}
