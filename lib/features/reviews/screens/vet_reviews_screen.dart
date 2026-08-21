import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/rating_stars_widget.dart';
import '../cubit/reviews_cubit.dart';
import '../models/review_model.dart';
import 'review_form_screen.dart';

class VetReviewsScreen extends StatefulWidget {
  const VetReviewsScreen({
    super.key,
    required this.vetId,
    required this.currentUserId,
  });

  final int vetId;
  final int currentUserId;

  @override
  State<VetReviewsScreen> createState() => _VetReviewsScreenState();
}

class _VetReviewsScreenState extends State<VetReviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewsCubit>().loadVetReviews(widget.vetId);
  }

  void _openEdit(ReviewModel review) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ReviewsCubit>(),
            child: ReviewFormScreen(
              vetId:          widget.vetId,
              bookingId:      0,
              existingReview: review,
            ),
          ),
        ))
        .then((changed) {
      if (changed == true && mounted) {
        context.read<ReviewsCubit>().loadVetReviews(widget.vetId);
      }
    });
  }

  void _confirmDelete(ReviewModel review) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          AppStrings.reviewsTitle,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: const Text(
          AppStrings.reviewDeleteConfirm,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context
            .read<ReviewsCubit>()
            .deleteReview(review.reviewId, vetId: widget.vetId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.reviewsTitle)),
      body: BlocConsumer<ReviewsCubit, ReviewsState>(
        listenWhen: (p, c) => c is ReviewsError,
        listener: (context, state) {
          if (state is ReviewsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message,
                  style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is ReviewsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ReviewsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ReviewsCubit>().loadVetReviews(widget.vetId),
            );
          }

          if (state is ReviewsLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<ReviewsCubit>().loadVetReviews(widget.vetId),
              child: CustomScrollView(
                slivers: [
                  // ── Summary header ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: _SummaryHeader(
                      average:      state.data.averageRating,
                      totalReviews: state.data.totalReviews,
                    ),
                  ),

                  // ── Empty state ──────────────────────────────────────
                  if (state.data.reviews.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined,
                                size: 56, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              AppStrings.reviewEmpty,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: state.data.reviews.length,
                        separatorBuilder: (_, i) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final r = state.data.reviews[i];
                          return _ReviewCard(
                            review:        r,
                            isOwner:       r.userId == widget.currentUserId,
                            onEdit:        () => _openEdit(r),
                            onDelete:      () => _confirmDelete(r),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Summary header ────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.average,
    required this.totalReviews,
  });

  final double average;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            average.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          RatingStarsWidget(
            rating: average,
            size:   28,
            color:  Colors.amber,
          ),
          const SizedBox(height: 8),
          Text(
            '$totalReviews ${AppStrings.reviewTotalCount}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
  });

  final ReviewModel review;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: name + stars + optional actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar initials
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    review.userFullName.isNotEmpty
                        ? review.userFullName[0]
                        : '؟',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userFullName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingStarsWidget(
                        rating: review.rating.toDouble(),
                        size:   16,
                      ),
                    ],
                  ),
                ),
                // Date
                Text(
                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            // Comment
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                review.comment!,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
              ),
            ],

            // Owner actions
            if (isOwner) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text(
                      'تعديل',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.error),
                    icon: const Icon(Icons.delete_outline, size: 15),
                    label: const Text(
                      'حذف',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'حاول تاني',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
