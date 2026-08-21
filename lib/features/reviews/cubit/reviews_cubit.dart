import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../repository/reviews_repository.dart';
import 'reviews_state.dart';

export 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit(this._repository) : super(const ReviewsInitial());

  final ReviewsRepository _repository;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadVetReviews(int vetId) async {
    emit(const ReviewsLoading());
    try {
      final data = await _repository.getVetReviews(vetId);
      if (isClosed) return;
      emit(ReviewsLoaded(data));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ReviewsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ReviewsError(AppStrings.unknownError));
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  bool _isSubmitting = false;

  Future<void> createReview({
    required int vetId,
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const ReviewActionLoading());
    try {
      await _repository.createReview(
        vetId:     vetId,
        bookingId: bookingId,
        rating:    rating,
        comment:   comment,
      );
      if (isClosed) return;
      emit(const ReviewActionSuccess(AppStrings.reviewSent));
    } on ApiException catch (e) {
      if (isClosed) return;
      // Intercept duplicate-review server error
      final msg = _isDuplicate(e.message)
          ? AppStrings.reviewDuplicate
          : e.message;
      emit(ReviewsError(msg));
    } catch (_) {
      if (isClosed) return;
      emit(const ReviewsError(AppStrings.unknownError));
    } finally {
      _isSubmitting = false;
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateReview(
    int id, {
    required int rating,
    String? comment,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const ReviewActionLoading());
    try {
      await _repository.updateReview(id, rating: rating, comment: comment);
      if (isClosed) return;
      emit(const ReviewActionSuccess(AppStrings.reviewUpdated));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ReviewsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ReviewsError(AppStrings.unknownError));
    } finally {
      _isSubmitting = false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteReview(int id, {required int vetId}) async {
    emit(const ReviewActionLoading());
    try {
      await _repository.deleteReview(id);
      if (isClosed) return;
      emit(const ReviewActionSuccess(AppStrings.reviewDeleted));
      await loadVetReviews(vetId);
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ReviewsError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ReviewsError(AppStrings.unknownError));
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  bool _isDuplicate(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('already') ||
        lower.contains('duplicate') ||
        lower.contains('exist') ||
        lower.contains('سبق') ||
        lower.contains('موجود');
  }
}
