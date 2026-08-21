import 'package:equatable/equatable.dart';
import '../models/consultation_model.dart';

abstract class ConsultationsState extends Equatable {
  const ConsultationsState();
  @override
  List<Object?> get props => [];
}

class ConsultationsInitial extends ConsultationsState {
  const ConsultationsInitial();
}

class ConsultationsLoading extends ConsultationsState {
  const ConsultationsLoading();
}

class ConsultationsLoaded extends ConsultationsState {
  const ConsultationsLoaded(this.consultations);
  final List<ConsultationModel> consultations;
  @override
  List<Object?> get props => [consultations];
}

class ConsultationsError extends ConsultationsState {
  const ConsultationsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ConsultationActionLoading extends ConsultationsState {
  const ConsultationActionLoading();
}

class ConsultationActionSuccess extends ConsultationsState {
  const ConsultationActionSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
