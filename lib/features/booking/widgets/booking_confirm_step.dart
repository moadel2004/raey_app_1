import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../cubit/booking_cubit.dart';

class BookingConfirmStep extends StatelessWidget {
  const BookingConfirmStep({super.key, required this.state});

  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final vet = state.selectedVet;
    final farm = state.selectedFarm;
    final date = state.scheduledDate;
    final time = state.scheduledTime;
    if (vet == null || date == null || time == null) {
      return const SizedBox.shrink();
    }

    final dateStr =
        '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص الحجز',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 14),
                    _SummaryRow(
                      icon: Icons.medical_services_outlined,
                      label: AppStrings.bookSummaryVet,
                      value: vet.fullName,
                    ),
                    if (state.bookingType == 'FarmVisit' && farm != null) ...[
                      const SizedBox(height: 12),
                      _SummaryRow(
                        icon: Icons.agriculture_outlined,
                        label: AppStrings.bookSummaryFarm,
                        value: '${farm.name} — ${farm.location}',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: state.bookingType == 'FarmVisit'
                          ? Icons.agriculture_outlined
                          : Icons.videocam_outlined,
                      label: AppStrings.bookSummaryType,
                      value: state.bookingType == 'FarmVisit'
                          ? AppStrings.bookingTypeFarmVisit
                          : AppStrings.bookingTypeOnline,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.calendar_today_outlined,
                      label: AppStrings.bookSummaryDate,
                      value: '$dateStr  $timeStr',
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.pets_outlined,
                      label: AppStrings.bookSummaryAnimals,
                      value: '${state.selectedAnimalIds.length} حيوانات',
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.attach_money_outlined,
                      label: 'السعر',
                      value: '${vet.consultationFee.toInt()} جنيه',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            label: AppStrings.bookSubmit,
            isLoading: state.isSubmitting,
            onPressed: state.isSubmitting
                ? null
                : () => context.read<BookingCubit>().submitBooking(),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
