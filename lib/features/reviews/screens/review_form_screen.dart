import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/rating_stars_widget.dart';
import '../cubit/reviews_cubit.dart';
import '../models/review_model.dart';

/// Form for creating OR editing a review.
///
/// Create: pass [vetId] + [bookingId].
/// Edit:   pass [existingReview] (vetId/bookingId unused).
class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({
    super.key,
    required this.vetId,
    required this.bookingId,
    this.existingReview,
  });

  final int vetId;
  final int bookingId;
  final ReviewModel? existingReview;

  bool get isEdit => existingReview != null;

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _commentCtrl = TextEditingController();
  int _rating = 0;

  static const _maxComment = 1000;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _rating = widget.existingReview!.rating;
      _commentCtrl.text = widget.existingReview!.comment ?? '';
    }
    _commentCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          AppStrings.reviewSelectRating,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (_commentCtrl.text.length > _maxComment) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          AppStrings.reviewCommentLimit,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    final cubit   = context.read<ReviewsCubit>();
    final comment = _commentCtrl.text.trim().isEmpty
        ? null
        : _commentCtrl.text.trim();

    if (widget.isEdit) {
      await cubit.updateReview(
        widget.existingReview!.reviewId,
        rating:  _rating,
        comment: comment,
      );
    } else {
      await cubit.createReview(
        vetId:     widget.vetId,
        bookingId: widget.bookingId,
        rating:    _rating,
        comment:   comment,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? AppStrings.reviewUpdate : AppStrings.reviewVet,
        ),
      ),
      body: BlocConsumer<ReviewsCubit, ReviewsState>(
        listenWhen: (p, c) =>
            c is ReviewActionSuccess || c is ReviewsError,
        listener: (context, state) {
          if (state is ReviewActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.green,
            ));
            Navigator.of(context).pop(true);
          } else if (state is ReviewsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          final isLoading = state is ReviewActionLoading;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // ── Stars ──────────────────────────────────────────────
                  const Text(
                    AppStrings.reviewYours,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RatingStarsWidget(
                      rating: _rating.toDouble(),
                      size:   44,
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _rating == 0
                          ? AppStrings.reviewSelectRating
                          : '$_rating / 5',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: _rating == 0
                            ? Colors.grey
                            : AppColors.primary,
                        fontWeight: _rating > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Comment ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.reviewComment,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_commentCtrl.text.length} / $_maxComment',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: _commentCtrl.text.length > _maxComment
                              ? AppColors.error
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentCtrl,
                    maxLines: 5,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقك هنا...',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ─────────────────────────────────────────────
                  CustomButton(
                    label: widget.isEdit
                        ? AppStrings.reviewUpdate
                        : AppStrings.reviewSubmit,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                ],
              ),
              if (isLoading)
                const Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(color: Colors.transparent),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
