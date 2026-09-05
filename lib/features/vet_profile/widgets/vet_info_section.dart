import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/rating_stars_widget.dart';
import '../../reviews/cubit/reviews_cubit.dart';
import '../../reviews/screens/vet_reviews_screen.dart';
import '../cubit/vet_profile_cubit.dart';
import 'vet_card_container.dart';

class VetInfoSection extends StatelessWidget {
  const VetInfoSection({super.key, required this.loaded});

  final VetProfileLoaded loaded;

  @override
  Widget build(BuildContext context) {
    final p = loaded.profile;
    return VetCardContainer(
      title: AppStrings.vetMyInfo,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primarySurface,
                child: Icon(
                  Icons.medical_services,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.phoneNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<ReviewsCubit>(),
                  child: VetReviewsScreen(vetId: p.vetId, currentUserId: 0),
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  RatingStarsWidget(rating: p.averageRating, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${p.averageRating.toStringAsFixed(1)} (${p.totalReviews} ${AppStrings.reviewTotalCount})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
