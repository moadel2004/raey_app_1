import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../farms/models/region_model.dart';
import '../models/dashboard_model.dart';
import '../repository/vet_profile_repository.dart';
import 'vet_profile_state.dart';

export 'vet_profile_state.dart';

class VetProfileCubit extends Cubit<VetProfileState> {
  VetProfileCubit(this._repository) : super(const VetProfileInitial());

  final VetProfileRepository _repository;

  /// Last successfully loaded state — kept so the UI can display data
  /// even while an action is in progress.
  VetProfileLoaded? _cached;
  VetProfileLoaded? get cached => _cached;

  // ── Load ─────────────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    if (state is VetProfileLoading) return;
    await _doLoad();
  }

  Future<void> _doLoad({
    List<RegionModel>? cachedRegions,
  }) async {
    emit(const VetProfileLoading());
    try {
      final profile       = await _repository.getProfile();
      if (isClosed) return;
      final availabilities = await _repository.getAvailability();
      if (isClosed) return;
      final allRegions    = cachedRegions ?? await _repository.getAllRegions();
      if (isClosed) return;

      DashboardModel? dashboard;
      try {
        dashboard = await _repository.getDashboard();
      } catch (_) {}
      if (isClosed) return;

      final loaded = VetProfileLoaded(
        profile:       profile,
        availabilities: availabilities,
        allRegions:    allRegions,
        dashboard:     dashboard,
      );
      _cached = loaded;
      emit(loaded);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(VetProfileError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const VetProfileError('تعذّر تحميل البروفايل، حاول تاني.'));
    }
  }

  Future<void> _reload() async =>
      _doLoad(cachedRegions: _cached?.allRegions);

  // ── Profile ──────────────────────────────────────────────────────────────────

  Future<void> updateProfile({
    String? bio,
    required int experienceYears,
    required double consultationFee,
  }) async {
    emit(const VetActionLoading());
    try {
      await _repository.updateProfile(
        bio: bio?.trim().isEmpty == true ? null : bio?.trim(),
        experienceYears: experienceYears,
        consultationFee: consultationFee,
        profileImageUrl: _cached?.profile.profileImageUrl,
      );
      if (isClosed) return;
      emit(const VetActionSuccess('تم تحديث البروفايل بنجاح'));
      await _reload();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(VetProfileError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const VetProfileError('تعذّر تحديث البروفايل، حاول تاني.'));
    }
  }

  // ── Regions ──────────────────────────────────────────────────────────────────

  Future<void> addRegion(int regionId) async {
    emit(const VetActionLoading());
    try {
      await _repository.addRegion(regionId);
      if (isClosed) return;
      emit(const VetActionSuccess('تمت إضافة المنطقة'));
      await _reload();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(VetProfileError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const VetProfileError('تعذّر إضافة المنطقة، حاول تاني.'));
    }
  }

  Future<void> removeRegion(int regionId) async {
    emit(const VetActionLoading());
    try {
      await _repository.removeRegion(regionId);
      if (isClosed) return;
      emit(const VetActionSuccess('تم إزالة المنطقة'));
      await _reload();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(VetProfileError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const VetProfileError('تعذّر إزالة المنطقة، حاول تاني.'));
    }
  }

  // ── Availability ─────────────────────────────────────────────────────────────

  Future<void> addAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    emit(const VetActionLoading());
    try {
      await _repository.addAvailability(
          dayOfWeek: dayOfWeek, startTime: startTime, endTime: endTime);
      if (isClosed) return;
      emit(const VetActionSuccess('تمت إضافة الميعاد'));
      await _reload();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(VetProfileError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const VetProfileError('تعذّر إضافة الميعاد، حاول تاني.'));
    }
  }

  Future<void> updateAvailability({
    required int id,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isActive,
  }) async {
    emit(const VetActionLoading());
    try {
      await _repository.updateAvailability(
        id: id,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        isActive: isActive,
      );
      if (isClosed) return;
      emit(const VetActionSuccess('تم تعديل الميعاد'));
      await _reload();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(VetProfileError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const VetProfileError('تعذّر تعديل الميعاد، حاول تاني.'));
    }
  }

  Future<void> deleteAvailability(int id) async {
    emit(const VetActionLoading());
    try {
      await _repository.deleteAvailability(id);
      if (isClosed) return;
      emit(const VetActionSuccess('تم حذف الميعاد'));
      await _reload();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(VetProfileError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const VetProfileError('تعذّر حذف الميعاد، حاول تاني.'));
    }
  }
}
