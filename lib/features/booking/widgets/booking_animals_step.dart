import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../cubit/booking_cubit.dart';
import 'booking_empty_view.dart';

class BookingAnimalsStep extends StatelessWidget {
  const BookingAnimalsStep({super.key, required this.state});

  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.farmAnimals.isEmpty) {
      return BookingEmptyView(
        icon: Icons.pets_outlined,
        message: AppStrings.bookNoAnimals,
        onRetry: () => context.read<BookingCubit>().retryLoadAnimals(),
        showRetry: state.error != null,
      );
    }
    final selected = state.selectedAnimalIds;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            itemCount: state.farmAnimals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final animal = state.farmAnimals[i];
              final isSelected = selected.contains(animal.id);
              return InkWell(
                onTap: () =>
                    context.read<BookingCubit>().toggleAnimal(animal.id),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : AppColors.surface,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${animal.type} — ${animal.breed}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${animal.genderAr}  •  ${animal.officialTagId}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            label: selected.isEmpty
                ? AppStrings.bookNextStep
                : '${AppStrings.bookNextStep} — ${selected.length} مختارين',
            onPressed: () => context.read<BookingCubit>().confirmAnimals(),
          ),
        ),
      ],
    );
  }
}
