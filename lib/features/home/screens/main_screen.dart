import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../cubit/home_cubit.dart';
import '../../../features/orders/cubit/orders_cubit.dart';
import '../../../features/orders/screens/orders_screen.dart';
import '../../../features/notifications/cubit/notifications_cubit.dart';
import '../../../features/notifications/screens/notifications_screen.dart';
import '../../../features/profile/cubit/profile_cubit.dart';
import '../../../features/profile/screens/profile_screen.dart';
import 'farmer_home_screen.dart';
import 'doctor_home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const LoadingOverlay();
        }
        if (state is HomeError) {
          return Scaffold(
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          );
        }
        if (state is HomeLoaded) {
          final homeWidget = state.user.isVeterinarian
              ? DoctorHomeScreen(user: state.user)
              : FarmerHomeScreen(user: state.user);

          final screens = [
            homeWidget,
            BlocProvider(
              create: (_) => sl<OrdersCubit>(),
              child: const OrdersScreen(),
            ),
            BlocProvider(
              create: (_) => sl<NotificationsCubit>(),
              child: const NotificationsScreen(),
            ),
            BlocProvider(
              create: (_) => sl<ProfileCubit>(),
              child: const ProfileScreen(),
            ),
          ];

          return Scaffold(
            backgroundColor: AppColors.background,
            body: screens[state.tabIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.tabIndex,
              onTap: (index) => context.read<HomeCubit>().setTab(index),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
                  label: 'الطلبات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none),
                  activeIcon: Icon(Icons.notifications),
                  label: 'الإشعارات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'حسابي',
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
