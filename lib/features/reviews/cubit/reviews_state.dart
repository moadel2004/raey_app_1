import 'package:equatable/equatable.dart';
import '../models/vet_reviews_model.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();
  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

class ReviewsLoading extends ReviewsState {
  const ReviewsLoading();
}

class ReviewsLoaded extends ReviewsState {
  const ReviewsLoaded(this.data);
  final VetReviewsModel data;
  @override
  List<Object?> get props => [data];
}

class ReviewsError extends ReviewsState {
  const ReviewsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ReviewActionLoading extends ReviewsState {
  const ReviewActionLoading();
}

class ReviewActionSuccess extends ReviewsState {
  const ReviewActionSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
