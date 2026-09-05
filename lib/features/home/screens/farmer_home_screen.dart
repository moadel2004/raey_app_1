import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/user_model.dart';
import '../cubit/home_cubit.dart';
import '../widgets/farmer_header_card.dart';
import '../widgets/farmer_service_cards.dart';
import '../widgets/farmer_stats_grid.dart';
import '../widgets/farmer_upcoming_bookings.dart';

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
    final switchToOrders = await context.push<bool>(
      AppRoutes.booking,
      extra: initialType,
    );
    if (switchToOrders == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<HomeCubit>().setTab(1);
      });
    }
  }

  void _openConsultationsList() {
    context.push(AppRoutes.consultations);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final loaded = state is HomeLoaded ? state : null;
        final dashboard = loaded?.dashboard;
        final isLoading = loaded?.isDashboardLoading ?? false;
        final error = loaded?.dashboardError;

        return Column(
          children: [
            FarmerHeaderCard(user: widget.user, dashboard: dashboard),
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
                      FarmerStatsGrid(
                        dashboard: dashboard,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 24),
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
                      FarmerServiceCards(
                        onOpenBooking: _openBookingFlow,
                        onOpenConsultations: _openConsultationsList,
                      ),
                      const SizedBox(height: 28),
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
                      FarmerUpcomingBookings(
                        dashboard: dashboard,
                        isLoading: isLoading,
                        error: error,
                        onRetry: () =>
                            context.read<HomeCubit>().loadDashboard(),
                      ),
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
}
