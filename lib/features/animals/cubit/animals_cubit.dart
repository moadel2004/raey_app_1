import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../repository/animals_repository.dart';
import 'animals_state.dart';

export 'animals_state.dart';

class AnimalsCubit extends Cubit<AnimalsState> {
  AnimalsCubit(this._repository) : super(const AnimalsInitial());

  final AnimalsRepository _repository;
  int? _farmId;

  Future<void> loadAnimals(int farmId) async {
    if (state is AnimalsLoading) return;
    _farmId = farmId;
    emit(const AnimalsLoading());
    try {
      final animals = await _repository.getAnimalsByFarm(farmId);
      if (isClosed) return;
      emit(AnimalsLoaded(animals));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(AnimalsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const AnimalsError('تعذّر تحميل الحيوانات، حاول تاني.'));
    }
  }

  Future<void> createAnimal({
    required String officialTagId,
    required String type,
    required String breed,
    required String gender,
    DateTime? birthDate,
    required int farmId,
  }) async {
    emit(const AnimalActionLoading());
    try {
      await _repository.createAnimal(
        officialTagId: officialTagId,
        type: type,
        breed: breed,
        gender: gender,
        birthDate: birthDate,
        farmId: farmId,
      );
      if (isClosed) return;
      emit(const AnimalActionSuccess('تم إضافة الحيوان بنجاح'));
      if (_farmId != null) await loadAnimals(_farmId!);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(AnimalsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const AnimalsError('تعذّر إضافة الحيوان، حاول تاني.'));
    }
  }

  Future<void> updateAnimal({
    required int id,
    required String type,
    required String breed,
    required String gender,
    DateTime? birthDate,
  }) async {
    emit(const AnimalActionLoading());
    try {
      await _repository.updateAnimal(
        id: id,
        type: type,
        breed: breed,
        gender: gender,
        birthDate: birthDate,
      );
      if (isClosed) return;
      emit(const AnimalActionSuccess('تم تعديل الحيوان بنجاح'));
      if (_farmId != null) await loadAnimals(_farmId!);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(AnimalsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const AnimalsError('تعذّر تعديل الحيوان، حاول تاني.'));
    }
  }

  Future<void> deleteAnimal(int id) async {
    emit(const AnimalActionLoading());
    try {
      await _repository.deleteAnimal(id);
      if (isClosed) return;
      emit(const AnimalActionSuccess('تم حذف الحيوان'));
      if (_farmId != null) await loadAnimals(_farmId!);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(AnimalsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const AnimalsError('تعذّر حذف الحيوان، حاول تاني.'));
    }
  }
}
