import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../cubit/booking_cubit.dart';

class BookingTypeDateStep extends StatefulWidget {
  const BookingTypeDateStep({super.key});

  @override
  State<BookingTypeDateStep> createState() => _BookingTypeDateStepState();
}

class _BookingTypeDateStepState extends State<BookingTypeDateStep> {
  Future<void> _pickDate(BookingFlowState state) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.scheduledDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: AppStrings.bookDateLabel,
    );
    if (picked != null && mounted) {
      context.read<BookingCubit>().setScheduledDate(picked);
    }
  }

  Future<void> _pickTime(BookingFlowState state) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: state.scheduledTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: AppStrings.bookTimeLabel,
    );
    if (picked != null && mounted) {
      context.read<BookingCubit>().setScheduledTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingFlowState>(
      builder: (context, state) {
        final date = state.scheduledDate;
        final time = state.scheduledTime;
        final dateStr = date == null
            ? 'اختار التاريخ'
            : '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
        final timeStr = time == null
            ? 'اختار الوقت'
            : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selector
                    const Text(
                      AppStrings.bookSummaryType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _TypeChip(
                          label: AppStrings.bookingTypeFarmVisit,
                          icon: Icons.agriculture_outlined,
                          selected: state.bookingType == 'FarmVisit',
                          onTap: () => context
                              .read<BookingCubit>()
                              .setBookingType('FarmVisit'),
                        ),
                        const SizedBox(width: 12),
                        _TypeChip(
                          label: AppStrings.bookingTypeOnline,
                          icon: Icons.videocam_outlined,
                          selected: state.bookingType == 'Online',
                          onTap: () => context
                              .read<BookingCubit>()
                              .setBookingType('Online'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Date
                    const Text(
                      AppStrings.bookDateLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PickerTile(
                      icon: Icons.calendar_today_outlined,
                      label: dateStr,
                      onTap: () => _pickDate(state),
                      hasValue: date != null,
                    ),
                    const SizedBox(height: 20),

                    // Time
                    const Text(
                      AppStrings.bookTimeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PickerTile(
                      icon: Icons.access_time_outlined,
                      label: timeStr,
                      onTap: () => _pickTime(state),
                      hasValue: time != null,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                label: AppStrings.bookNextStep,
                onPressed: () => context.read<BookingCubit>().goToConfirm(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : AppColors.textMedium),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.hasValue,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasValue ? AppColors.primary : AppColors.textLight,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: hasValue ? AppColors.textDark : AppColors.textLight,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
