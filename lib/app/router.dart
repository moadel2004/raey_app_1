import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../core/di/injection_container.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/farms/cubit/farms_cubit.dart';
import '../features/farms/screens/farms_list_screen.dart';
import '../features/home/cubit/home_cubit.dart';
import '../features/home/screens/main_screen.dart';
import '../features/vet_profile/cubit/vet_profile_cubit.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<HomeCubit>()),
            BlocProvider(create: (_) => sl<VetProfileCubit>()),
          ],
          child: const MainScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.farms,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<FarmsCubit>(),
          child: const FarmsListScreen(),
        ),
      ),
    ],
  );
}
