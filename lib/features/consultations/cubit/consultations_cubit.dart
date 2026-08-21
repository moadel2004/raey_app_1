import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../auth/repository/auth_repository.dart';
import '../../booking/models/vet_summary_model.dart';
import '../repository/consultations_repository.dart';
import 'consultations_state.dart';

export 'consultations_state.dart';

class ConsultationsCubit extends Cubit<ConsultationsState> {
  ConsultationsCubit(this._repository, this._authRepository)
      : super(const ConsultationsInitial());

  final ConsultationsRepository _repository;
  final AuthRepository _authRepository;

  bool get isVet =>
      _authRepository.getCachedUser()?.isVeterinarian ?? false;

  // ── Vets ─────────────────────────────────────────────────────────────────

  Future<List<VetSummaryModel>> getAllVets() =>
      _repository.getAllVets();

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadConsultations() async {
    emit(const ConsultationsLoading());
    try {
      final list = isVet
          ? await _repository.getVetConsultations()
          : await _repository.getMyConsultations();
      if (isClosed) return;
      emit(ConsultationsLoaded(list));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ConsultationsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ConsultationsError(AppStrings.unknownError));
    }
  }

  // ── Create (farmer only) ──────────────────────────────────────────────────

  bool _isSubmitting = false;

  Future<void> createConsultation({
    required int veterinarianId,
    required String subject,
    String? description,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const ConsultationActionLoading());
    try {
      await _repository.createConsultation(
        veterinarianId: veterinarianId,
        subject: subject,
        description: description,
      );
      if (isClosed) return;
      emit(const ConsultationActionSuccess(AppStrings.consultationSent));
      await loadConsultations();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ConsultationsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ConsultationsError(AppStrings.unknownError));
    } finally {
      _isSubmitting = false;
    }
  }

  // ── Actions (vet only) ────────────────────────────────────────────────────

  Future<void> acceptConsultation(int id) async {
    emit(const ConsultationActionLoading());
    try {
      await _repository.acceptConsultation(id);
      if (isClosed) return;
      emit(const ConsultationActionSuccess(AppStrings.consultationAccepted));
      await loadConsultations();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ConsultationsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ConsultationsError(AppStrings.unknownError));
    }
  }

  Future<void> rejectConsultation(int id) async {
    emit(const ConsultationActionLoading());
    try {
      await _repository.rejectConsultation(id);
      if (isClosed) return;
      emit(const ConsultationActionSuccess(AppStrings.consultationRejected));
      await loadConsultations();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ConsultationsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ConsultationsError(AppStrings.unknownError));
    }
  }

  Future<void> closeConsultation(int id) async {
    emit(const ConsultationActionLoading());
    try {
      await _repository.closeConsultation(id);
      if (isClosed) return;
      emit(const ConsultationActionSuccess(AppStrings.consultationClosed));
      await loadConsultations();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ConsultationsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ConsultationsError(AppStrings.unknownError));
    }
  }
}
