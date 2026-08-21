import 'package:equatable/equatable.dart';
import '../../auth/models/user_model.dart';
import '../models/dashboard_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(
    this.user, {
    this.tabIndex = 0,
    this.dashboard,
    this.isDashboardLoading = false,
    this.dashboardError,
  });

  final UserModel user;
  final int tabIndex;
  final DashboardModel? dashboard;
  final bool isDashboardLoading;
  final String? dashboardError;

  HomeLoaded copyWith({
    int? tabIndex,
    DashboardModel? dashboard,
    bool? isDashboardLoading,
    String? dashboardError,
    bool clearDashboardError = false,
  }) =>
      HomeLoaded(
        user,
        tabIndex:            tabIndex ?? this.tabIndex,
        dashboard:           dashboard ?? this.dashboard,
        isDashboardLoading:  isDashboardLoading ?? this.isDashboardLoading,
        dashboardError:      clearDashboardError ? null : (dashboardError ?? this.dashboardError),
      );

  @override
  List<Object?> get props =>
      [user, tabIndex, dashboard, isDashboardLoading, dashboardError];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
