import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../animals/models/animal_model.dart';
import '../../farms/models/farm_model.dart';
import '../models/vet_summary_model.dart';

class BookingFlowState extends Equatable {
  const BookingFlowState({
    this.step = 0,
    this.farms = const [],
    this.selectedFarm,
    this.vets = const [],
    this.selectedVet,
    this.farmAnimals = const [],
    this.selectedAnimalIds = const [],
    this.bookingType = 'FarmVisit',
    this.scheduledDate,
    this.scheduledTime,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  final int step;
  final List<FarmModel> farms;
  final FarmModel? selectedFarm;
  final List<VetSummaryModel> vets;
  final VetSummaryModel? selectedVet;
  final List<AnimalModel> farmAnimals;
  final List<int> selectedAnimalIds;
  final String bookingType;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final bool isLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  BookingFlowState copyWith({
    int? step,
    List<FarmModel>? farms,
    FarmModel? selectedFarm,
    bool clearSelectedFarm = false,
    List<VetSummaryModel>? vets,
    VetSummaryModel? selectedVet,
    bool clearSelectedVet = false,
    List<AnimalModel>? farmAnimals,
    List<int>? selectedAnimalIds,
    String? bookingType,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    TimeOfDay? scheduledTime,
    bool clearScheduledTime = false,
    bool? isLoading,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    bool clearError = false,
  }) =>
      BookingFlowState(
        step:             step ?? this.step,
        farms:            farms ?? this.farms,
        selectedFarm:     clearSelectedFarm ? null : (selectedFarm ?? this.selectedFarm),
        vets:             vets ?? this.vets,
        selectedVet:      clearSelectedVet ? null : (selectedVet ?? this.selectedVet),
        farmAnimals:      farmAnimals ?? this.farmAnimals,
        selectedAnimalIds: selectedAnimalIds ?? this.selectedAnimalIds,
        bookingType:      bookingType ?? this.bookingType,
        scheduledDate:    clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
        scheduledTime:    clearScheduledTime ? null : (scheduledTime ?? this.scheduledTime),
        isLoading:        isLoading ?? this.isLoading,
        isSubmitting:     isSubmitting ?? this.isSubmitting,
        isSuccess:        isSuccess ?? this.isSuccess,
        error:            clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [
        step, farms, selectedFarm, vets, selectedVet,
        farmAnimals, selectedAnimalIds, bookingType,
        scheduledDate, scheduledTime,
        isLoading, isSubmitting, isSuccess, error,
      ];
}
