import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../auth/repository/auth_repository.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';
import '../repository/medical_repository.dart';
import 'medical_state.dart';

export 'medical_state.dart';

class MedicalCubit extends Cubit<MedicalState> {
  MedicalCubit(this._repository, this._authRepository)
      : super(const MedicalInitial());

  final MedicalRepository _repository;
  final AuthRepository _authRepository;

  bool get isVet =>
      _authRepository.getCachedUser()?.isVeterinarian ?? false;

  // ── List (vet search screen) ──────────────────────────────────────────────

  Future<void> loadRecords({
    int? animalId,
    int? veterinarianId,
    String? visitType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(const MedicalLoading());
    try {
      final list = await _repository.searchRecords(
        animalId:       animalId,
        veterinarianId: veterinarianId,
        visitType:      visitType,
        fromDate:       fromDate,
        toDate:         toDate,
      );
      if (isClosed) return;
      emit(MedicalRecordsLoaded(list));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MedicalError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const MedicalError(AppStrings.unknownError));
    }
  }

  // ── Single record (details screen) ────────────────────────────────────────

  Future<void> loadRecord(int id) async {
    emit(const MedicalLoading());
    try {
      final record = await _repository.getRecord(id);
      if (isClosed) return;
      emit(MedicalRecordLoaded(record));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MedicalError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const MedicalError(AppStrings.unknownError));
    }
  }

  // ── Change history (inside details screen) ────────────────────────────────

  Future<void> loadRecordChanges(int id) async {
    // Keep the record in view — don't emit Loading (would clear current data)
    MedicalRecordModel? current;
    final s = state;
    if (s is MedicalRecordLoaded)   current = s.record;
    if (s is RecordChangesLoaded)   current = s.record;

    if (current == null) {
      // Fallback: fetch record first
      await loadRecord(id);
      final s2 = state;
      if (s2 is MedicalRecordLoaded) current = s2.record;
      if (current == null) return; // error already emitted
    }

    try {
      final changes = await _repository.getRecordChanges(id);
      if (isClosed) return;
      emit(RecordChangesLoaded(record: current, changes: changes));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MedicalError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const MedicalError(AppStrings.unknownError));
    }
  }

  // ── Animal history screen ─────────────────────────────────────────────────

  Future<void> loadAnimalHistory(int animalId) async {
    emit(const MedicalLoading());
    try {
      final history = await _repository.getAnimalHistory(animalId);
      if (isClosed) return;
      emit(AnimalHistoryLoaded(history));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MedicalError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const MedicalError(AppStrings.unknownError));
    }
  }

  // ── Create (vet only) ─────────────────────────────────────────────────────

  bool _isSubmitting = false;

  Future<void> createRecord({
    required int animalId,
    required int vetId,       // from VetProfileCubit.cached?.profile.vetId
    required int bookingId,
    required String visitType,
    String? symptoms,
    String? diagnosis,
    String? notes,
    List<PrescriptionModel> prescriptions = const [],
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const MedicalActionLoading());
    try {
      await _repository.createRecord(
        animalId:      animalId,
        vetId:         vetId,
        bookingId:     bookingId,
        visitType:     visitType,
        symptoms:      symptoms,
        diagnosis:     diagnosis,
        notes:         notes,
        prescriptions: prescriptions,
      );
      if (isClosed) return;
      emit(const MedicalActionSuccess(AppStrings.medicalRecordSaved));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MedicalError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const MedicalError(AppStrings.unknownError));
    } finally {
      _isSubmitting = false;
    }
  }

  // ── Update (vet only) ─────────────────────────────────────────────────────

  Future<void> updateRecord(
    int id, {
    required String visitType,
    String? symptoms,
    String? diagnosis,
    String? notes,
    List<PrescriptionModel> prescriptions = const [],
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const MedicalActionLoading());
    try {
      await _repository.updateRecord(
        id,
        visitType:     visitType,
        symptoms:      symptoms,
        diagnosis:     diagnosis,
        notes:         notes,
        prescriptions: prescriptions,
      );
      if (isClosed) return;
      emit(const MedicalActionSuccess(AppStrings.medicalRecordUpdated));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MedicalError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const MedicalError(AppStrings.unknownError));
    } finally {
      _isSubmitting = false;
    }
  }

  // ── Delete (vet only) ─────────────────────────────────────────────────────

  Future<void> deleteRecord(int id) async {
    emit(const MedicalActionLoading());
    try {
      await _repository.deleteRecord(id);
      if (isClosed) return;
      emit(const MedicalActionSuccess(AppStrings.medicalRecordDeleted));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(MedicalError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const MedicalError(AppStrings.unknownError));
    }
  }
}
