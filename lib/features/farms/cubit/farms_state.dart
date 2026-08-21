import 'package:equatable/equatable.dart';
import '../models/farm_model.dart';
import '../models/region_model.dart';

abstract class FarmsState extends Equatable {
  const FarmsState();
  @override
  List<Object?> get props => [];
}

class FarmsInitial extends FarmsState {
  const FarmsInitial();
}

class FarmsLoading extends FarmsState {
  const FarmsLoading();
}

class FarmsLoaded extends FarmsState {
  const FarmsLoaded(this.farms, {this.regions = const []});
  final List<FarmModel> farms;
  final List<RegionModel> regions;
  @override
  List<Object?> get props => [farms, regions];
}

class FarmsError extends FarmsState {
  const FarmsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// حالات العمليات (إضافة / تعديل / حذف)
class FarmActionLoading extends FarmsState {
  const FarmActionLoading();
}

class FarmActionSuccess extends FarmsState {
  const FarmActionSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
