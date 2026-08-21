import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../models/region_model.dart';
import '../repository/farms_repository.dart';
import 'farms_state.dart';

export 'farms_state.dart';

class FarmsCubit extends Cubit<FarmsState> {
  FarmsCubit(this._repository) : super(const FarmsInitial());

  final FarmsRepository _repository;

  List<RegionModel> _regions = [];
  List<RegionModel> get regions => _regions;

  Future<void> loadFarms() async {
    if (state is FarmsLoading) return;
    emit(const FarmsLoading());
    try {
      final farms = await _repository.getFarms();
      if (isClosed) return;
      emit(FarmsLoaded(farms, regions: _regions));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(FarmsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const FarmsError('تعذّر تحميل المزارع، حاول تاني.'));
    }
  }

  Future<void> loadRegions() async {
    try {
      _regions = await _repository.getRegions();
    } catch (_) {
      _regions = [];
    }
  }

  Future<void> createFarm({
    required String name,
    required String location,
    required int regionId,
  }) async {
    emit(const FarmActionLoading());
    try {
      await _repository.createFarm(name: name, location: location, regionId: regionId);
      if (isClosed) return;
      emit(const FarmActionSuccess('تم إضافة المزرعة بنجاح'));
      await loadFarms();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(FarmsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const FarmsError('تعذّر إضافة المزرعة، حاول تاني.'));
    }
  }

  Future<void> updateFarm({
    required int id,
    required String name,
    required String location,
    required int regionId,
  }) async {
    emit(const FarmActionLoading());
    try {
      await _repository.updateFarm(
          id: id, name: name, location: location, regionId: regionId);
      if (isClosed) return;
      emit(const FarmActionSuccess('تم تعديل المزرعة بنجاح'));
      await loadFarms();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(FarmsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const FarmsError('تعذّر تعديل المزرعة، حاول تاني.'));
    }
  }

  Future<void> deleteFarm(int id) async {
    emit(const FarmActionLoading());
    try {
      await _repository.deleteFarm(id);
      if (isClosed) return;
      emit(const FarmActionSuccess('تم حذف المزرعة'));
      await loadFarms();
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(FarmsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const FarmsError('تعذّر حذف المزرعة، حاول تاني.'));
    }
  }
}
