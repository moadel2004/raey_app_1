import 'package:equatable/equatable.dart';
import '../models/animal_medical_history_model.dart';
import '../models/medical_record_model.dart';
import '../models/record_change_model.dart';

abstract class MedicalState extends Equatable {
  const MedicalState();
  @override
  List<Object?> get props => [];
}

class MedicalInitial extends MedicalState {
  const MedicalInitial();
}

class MedicalLoading extends MedicalState {
  const MedicalLoading();
}

// List of records (vet search screen)
class MedicalRecordsLoaded extends MedicalState {
  const MedicalRecordsLoaded(this.records);
  final List<MedicalRecordModel> records;
  @override
  List<Object?> get props => [records];
}

// Single record (details screen)
class MedicalRecordLoaded extends MedicalState {
  const MedicalRecordLoaded(this.record);
  final MedicalRecordModel record;
  @override
  List<Object?> get props => [record];
}

// Record + its change history
class RecordChangesLoaded extends MedicalState {
  const RecordChangesLoaded({required this.record, required this.changes});
  final MedicalRecordModel record;
  final List<RecordChangeModel> changes;
  @override
  List<Object?> get props => [record, changes];
}

// Animal full history (animal_medical_history_screen)
class AnimalHistoryLoaded extends MedicalState {
  const AnimalHistoryLoaded(this.history);
  final AnimalMedicalHistoryModel history;
  @override
  List<Object?> get props => [history];
}

class MedicalActionLoading extends MedicalState {
  const MedicalActionLoading();
}

class MedicalActionSuccess extends MedicalState {
  const MedicalActionSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class MedicalError extends MedicalState {
  const MedicalError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
