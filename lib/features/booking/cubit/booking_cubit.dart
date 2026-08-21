import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../animals/repository/animals_repository.dart';
import '../../farms/models/farm_model.dart';
import '../../farms/repository/farms_repository.dart';
import '../models/vet_summary_model.dart';
import '../repository/booking_repository.dart';
import 'booking_state.dart';

export 'booking_state.dart';

class BookingCubit extends Cubit<BookingFlowState> {
  BookingCubit(this._repo, this._farmsRepo, this._animalsRepo)
      : super(const BookingFlowState());

  final BookingRepository _repo;
  final FarmsRepository _farmsRepo;
  final AnimalsRepository _animalsRepo;

  void setInitialType(String type) {
    emit(state.copyWith(bookingType: type));
  }

  Future<void> loadFarms() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final farms = await _farmsRepo.getFarms();
      if (isClosed) return;
      emit(state.copyWith(farms: farms, isLoading: false));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: AppStrings.unknownError));
    }
  }

  Future<void> selectFarm(FarmModel farm) async {
    emit(state.copyWith(
      step: 1,
      selectedFarm: farm,
      vets: [],
      clearSelectedVet: true,
      isLoading: true,
      clearError: true,
    ));
    try {
      final vets = await _repo.getVetsByRegion(farm.regionId);
      if (isClosed) return;
      emit(state.copyWith(vets: vets, isLoading: false));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: AppStrings.unknownError));
    }
  }

  Future<void> retryLoadVets() async {
    final farm = state.selectedFarm;
    if (farm == null) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final vets = await _repo.getVetsByRegion(farm.regionId);
      if (isClosed) return;
      emit(state.copyWith(vets: vets, isLoading: false));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: AppStrings.unknownError));
    }
  }

  Future<void> selectVet(VetSummaryModel vet) async {
    final farm = state.selectedFarm;
    if (farm == null) return;

    emit(state.copyWith(
      step: 2,
      selectedVet: vet,
      farmAnimals: [],
      selectedAnimalIds: [],
      isLoading: true,
      clearError: true,
    ));
    try {
      final animals = await _animalsRepo.getAnimalsByFarm(farm.id);
      if (isClosed) return;
      emit(state.copyWith(farmAnimals: animals, isLoading: false));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: AppStrings.unknownError));
    }
  }

  Future<void> retryLoadAnimals() async {
    final farm = state.selectedFarm;
    if (farm == null) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final animals = await _animalsRepo.getAnimalsByFarm(farm.id);
      if (isClosed) return;
      emit(state.copyWith(farmAnimals: animals, isLoading: false));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: AppStrings.unknownError));
    }
  }

  void toggleAnimal(int id) {
    final current = List<int>.from(state.selectedAnimalIds);
    current.contains(id) ? current.remove(id) : current.add(id);
    emit(state.copyWith(selectedAnimalIds: current, clearError: true));
  }

  bool confirmAnimals() {
    if (state.selectedAnimalIds.isEmpty) {
      emit(state.copyWith(error: AppStrings.bookMinOneAnimal));
      return false;
    }
    emit(state.copyWith(step: 3, clearError: true));
    return true;
  }

  void setBookingType(String type) {
    emit(state.copyWith(bookingType: type));
  }

  void setScheduledDate(DateTime date) {
    emit(state.copyWith(scheduledDate: date, clearError: true));
  }

  void setScheduledTime(TimeOfDay time) {
    emit(state.copyWith(scheduledTime: time, clearError: true));
  }

  bool goToConfirm() {
    if (state.scheduledDate == null) {
      emit(state.copyWith(error: AppStrings.bookSelectDate));
      return false;
    }
    if (state.scheduledTime == null) {
      emit(state.copyWith(error: AppStrings.bookSelectTime));
      return false;
    }
    emit(state.copyWith(step: 4, clearError: true));
    return true;
  }

  void prevStep() {
    if (state.step > 0) {
      emit(state.copyWith(step: state.step - 1, clearError: true));
    }
  }

  Future<void> submitBooking() async {
    if (state.isSubmitting || state.isSuccess) return;
    final vet = state.selectedVet;
    final date = state.scheduledDate;
    final time = state.scheduledTime;
    if (vet == null || date == null || time == null) return;

    final scheduledAt = DateTime(
      date.year, date.month, date.day,
      time.hour, time.minute,
    );

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _repo.createBooking(
        vetId: vet.vetId,
        farmId: state.bookingType == 'FarmVisit' ? state.selectedFarm?.id : null,
        type: state.bookingType,
        scheduledAt: scheduledAt,
        animalIds: state.selectedAnimalIds,
      );
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, error: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, error: 'تعذّر إرسال الطلب، حاول تاني.'));
    }
  }
}
