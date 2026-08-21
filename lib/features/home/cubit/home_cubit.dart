import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../repository/home_repository.dart';
import 'home_state.dart';

export 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeInitial());

  final HomeRepository _repository;

  void setTab(int index) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(tabIndex: index));
    }
  }

  Future<void> getUserData() async {
    emit(const HomeLoading());
    try {
      final user = await _repository.getUserData();
      if (isClosed) return;
      emit(HomeLoaded(user));
    } catch (e) {
      if (isClosed) return;
      emit(HomeError(e.toString()));
    }
  }

  Future<void> loadDashboard() async {
    if (state is! HomeLoaded) return;
    emit((state as HomeLoaded).copyWith(
      isDashboardLoading: true,
      clearDashboardError: true,
    ));
    try {
      final dashboard = await _repository.getDashboard();
      if (isClosed) return;
      if (state is! HomeLoaded) return;
      emit((state as HomeLoaded).copyWith(
        dashboard: dashboard,
        isDashboardLoading: false,
      ));
    } on ApiException catch (e) {
      if (isClosed) return;
      if (state is! HomeLoaded) return;
      emit((state as HomeLoaded).copyWith(
        isDashboardLoading: false,
        dashboardError: e.message,
      ));
    } catch (_) {
      if (isClosed) return;
      if (state is! HomeLoaded) return;
      emit((state as HomeLoaded).copyWith(
        isDashboardLoading: false,
        dashboardError: AppStrings.unknownError,
      ));
    }
  }
}
