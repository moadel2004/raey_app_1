import 'package:equatable/equatable.dart';
import '../../farms/models/region_model.dart';
import '../models/availability_model.dart';
import '../models/dashboard_model.dart';
import '../models/vet_profile_model.dart';

abstract class VetProfileState extends Equatable {
  const VetProfileState();
  @override
  List<Object?> get props => [];
}

class VetProfileInitial extends VetProfileState {
  const VetProfileInitial();
}

class VetProfileLoading extends VetProfileState {
  const VetProfileLoading();
}

class VetProfileLoaded extends VetProfileState {
  const VetProfileLoaded({
    required this.profile,
    required this.availabilities,
    required this.allRegions,
    this.dashboard,
  });

  final VetProfileModel profile;
  final List<AvailabilityModel> availabilities;
  final List<RegionModel> allRegions;
  final DashboardModel? dashboard;

  @override
  List<Object?> get props => [profile, availabilities, allRegions, dashboard];
}

class VetProfileError extends VetProfileState {
  const VetProfileError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class VetActionLoading extends VetProfileState {
  const VetActionLoading();
}

class VetActionSuccess extends VetProfileState {
  const VetActionSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
