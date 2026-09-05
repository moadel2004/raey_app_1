import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/rating_stars_widget.dart';
import '../models/vet_summary_model.dart';

class BookingVetCard extends StatelessWidget {
  const BookingVetCard({
    super.key,
    required this.vet,
    required this.onSelect,
    this.onViewReviews,
  });

  final VetSummaryModel vet;
  final VoidCallback onSelect;
  final VoidCallback? onViewReviews;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + fee row
              Row(
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vet.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '${vet.consultationFee.toInt()} جنيه',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Experience
              Text(
                '${vet.experienceYears} سنين خبرة',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              // Stars row
              Row(
                children: [
                  RatingStarsWidget(rating: vet.averageRating, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    vet.averageRating > 0
                        ? vet.averageRating.toStringAsFixed(1)
                        : AppStrings.reviewEmpty,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      color: vet.averageRating > 0
                          ? AppColors.textMedium
                          : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (onViewReviews != null)
                    TextButton(
                      onPressed: onViewReviews,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        AppStrings.reviewsTitle,
                        style: TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
