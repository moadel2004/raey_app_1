import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../core/di/injection_container.dart';
import '../features/animals/cubit/animals_cubit.dart';
import '../features/animals/models/animal_model.dart';
import '../features/animals/screens/animal_form_screen.dart';
import '../features/animals/screens/animals_list_screen.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/booking/cubit/booking_cubit.dart';
import '../features/booking/screens/booking_flow_screen.dart';
import '../features/consultations/cubit/consultations_cubit.dart';
import '../features/consultations/screens/consultations_list_screen.dart';
import '../features/farms/cubit/farms_cubit.dart';
import '../features/farms/models/farm_model.dart';
import '../features/farms/screens/farm_form_screen.dart';
import '../features/farms/screens/farms_list_screen.dart';
import '../features/home/cubit/home_cubit.dart';
import '../features/home/screens/main_screen.dart';
import '../features/medical/cubit/medical_cubit.dart';
import '../features/medical/screens/medical_records_list_screen.dart';
import '../features/payment/screens/payment_screen.dart';
import '../features/reviews/cubit/reviews_cubit.dart';
import '../features/reviews/screens/vet_reviews_screen.dart';
import '../features/vet_profile/cubit/vet_profile_cubit.dart';
import '../features/vet_profile/screens/availability_screen.dart';
import '../features/vet_profile/screens/vet_profile_screen.dart';

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
      GoRoute(
        path: AppRoutes.farmForm,
        builder: (context, state) {
          final farm = state.extra as FarmModel?;
          return BlocProvider(
            create: (_) => sl<FarmsCubit>(),
            child: FarmFormScreen(farm: farm),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.animals,
        builder: (context, state) {
          final farm = state.extra as FarmModel;
          return BlocProvider(
            create: (_) => sl<AnimalsCubit>(),
            child: AnimalsListScreen(farm: farm),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.animalForm,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final farmId = extra?['farmId'] as int? ?? 0;
          final animal = extra?['animal'] as AnimalModel?;
          return BlocProvider(
            create: (_) => sl<AnimalsCubit>(),
            child: AnimalFormScreen(farmId: farmId, animal: animal),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.booking,
        builder: (context, state) {
          final initialType = state.extra as String? ?? 'FarmVisit';
          return BlocProvider(
            create: (_) => sl<BookingCubit>(),
            child: BookingFlowScreen(initialType: initialType),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.consultations,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ConsultationsCubit>(),
          child: const ConsultationsListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.vetProfile,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<VetProfileCubit>(),
          child: const VetProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.availability,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<VetProfileCubit>(),
          child: const AvailabilityScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.medicalRecords,
        builder: (context, state) {
          final vetId = state.extra as int? ?? 0;
          return BlocProvider(
            create: (_) => sl<MedicalCubit>(),
            child: MedicalRecordsListScreen(vetId: vetId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.vetReviews,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final vetId = extra?['vetId'] as int? ?? 0;
          final currentUserId = extra?['currentUserId'] as int? ?? 0;
          return BlocProvider(
            create: (_) => sl<ReviewsCubit>(),
            child: VetReviewsScreen(vetId: vetId, currentUserId: currentUserId),
          );
        },
      ),
    ],
  );
}
