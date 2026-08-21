import 'package:equatable/equatable.dart';
import '../models/animal_model.dart';

abstract class AnimalsState extends Equatable {
  const AnimalsState();
  @override
  List<Object?> get props => [];
}

class AnimalsInitial extends AnimalsState {
  const AnimalsInitial();
}

class AnimalsLoading extends AnimalsState {
  const AnimalsLoading();
}

class AnimalsLoaded extends AnimalsState {
  const AnimalsLoaded(this.animals);
  final List<AnimalModel> animals;
  @override
  List<Object?> get props => [animals];
}

class AnimalsError extends AnimalsState {
  const AnimalsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class AnimalActionLoading extends AnimalsState {
  const AnimalActionLoading();
}

class AnimalActionSuccess extends AnimalsState {
  const AnimalActionSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
