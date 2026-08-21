import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/animals/cubit/animals_cubit.dart';
import '../../features/animals/repository/animals_repository.dart';
import '../../features/booking/cubit/booking_cubit.dart';
import '../../features/booking/repository/booking_repository.dart';
import '../../features/consultations/cubit/consultations_cubit.dart';
import '../../features/consultations/cubit/chat_cubit.dart';
import '../../features/consultations/repository/consultations_repository.dart';
import '../../features/consultations/repository/chat_repository.dart';
import '../../features/medical/cubit/medical_cubit.dart';
import '../../features/medical/repository/medical_repository.dart';
import '../../features/reviews/cubit/reviews_cubit.dart';
import '../../features/reviews/repository/reviews_repository.dart';
import '../../features/vet_profile/cubit/vet_profile_cubit.dart';
import '../../features/vet_profile/repository/vet_profile_repository.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/farms/cubit/farms_cubit.dart';
import '../../features/farms/repository/farms_repository.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/repository/home_repository.dart';
import '../../features/notifications/cubit/notifications_cubit.dart';
import '../../features/orders/cubit/orders_cubit.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ── External ───────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  // ── Core services ─────────────────────────────────────────────────────────
  sl.registerSingleton<StorageService>(StorageService(prefs));
  sl.registerSingleton<ApiClient>(ApiClient(sl<StorageService>()));

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<ApiClient>(), sl<StorageService>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepository(sl<AuthRepository>(), sl<ApiClient>()),
  );

  // ── Cubits ────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthRepository>()));
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl<HomeRepository>()));
  sl.registerFactory<OrdersCubit>(() => OrdersCubit(sl<ApiClient>(), sl<AuthRepository>()));
  sl.registerFactory<NotificationsCubit>(() => NotificationsCubit());
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<AuthRepository>()));

  sl.registerLazySingleton<FarmsRepository>(
    () => FarmsRepository(sl<ApiClient>()),
  );
  sl.registerFactory<FarmsCubit>(() => FarmsCubit(sl<FarmsRepository>()));

  sl.registerLazySingleton<AnimalsRepository>(
    () => AnimalsRepository(sl<ApiClient>()),
  );
  sl.registerFactory<AnimalsCubit>(() => AnimalsCubit(sl<AnimalsRepository>()));

  sl.registerLazySingleton<VetProfileRepository>(
    () => VetProfileRepository(sl<ApiClient>()),
  );
  sl.registerFactory<VetProfileCubit>(
    () => VetProfileCubit(sl<VetProfileRepository>()),
  );

  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepository(sl<ApiClient>()),
  );
  sl.registerFactory<BookingCubit>(
    () => BookingCubit(
      sl<BookingRepository>(),
      sl<FarmsRepository>(),
      sl<AnimalsRepository>(),
    ),
  );

  sl.registerLazySingleton<ConsultationsRepository>(
    () => ConsultationsRepository(sl<ApiClient>()),
  );
  sl.registerFactory<ConsultationsCubit>(
    () => ConsultationsCubit(sl<ConsultationsRepository>(), sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepository(sl<ApiClient>()),
  );
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(sl<ChatRepository>()),
  );

  sl.registerLazySingleton<MedicalRepository>(
    () => MedicalRepository(sl<ApiClient>()),
  );
  sl.registerFactory<MedicalCubit>(
    () => MedicalCubit(sl<MedicalRepository>(), sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepository(sl<ApiClient>()),
  );
  sl.registerFactory<ReviewsCubit>(
    () => ReviewsCubit(sl<ReviewsRepository>()),
  );
}
