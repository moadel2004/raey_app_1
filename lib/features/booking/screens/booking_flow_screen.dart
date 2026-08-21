import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/rating_stars_widget.dart';
import '../../reviews/cubit/reviews_cubit.dart';
import '../../reviews/screens/vet_reviews_screen.dart';
import '../cubit/booking_cubit.dart';
import '../models/vet_summary_model.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key, this.initialType = 'FarmVisit'});
  final String initialType;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<BookingCubit>();
    cubit.setInitialType(widget.initialType);
    cubit.loadFarms();
  }

  void _handleBack() {
    final cubit = context.read<BookingCubit>();
    if (cubit.state.step > 0 && !cubit.state.isSuccess) {
      cubit.prevStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  String _appBarTitle(int step, bool isSuccess) {
    if (isSuccess) return AppStrings.bookConfirm;
    return const [
      AppStrings.bookSelectFarm,
      AppStrings.bookSelectVet,
      AppStrings.bookSelectAnimals,
      AppStrings.bookTypeAndDate,
      AppStrings.bookConfirm,
    ][step.clamp(0, 4)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingFlowState>(
      listenWhen: (p, c) => c.error != null && c.error != p.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.error,
          ));
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            // didPop=true means a programmatic pop already fired — don't pop again
            if (didPop) return;
            _handleBack();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _handleBack,
              ),
              title: Text(_appBarTitle(state.step, state.isSuccess)),
            ),
            body: state.isSuccess
                ? _SuccessView(onDone: () => Navigator.of(context).pop(true))
                : Column(
                    children: [
                      _StepDots(currentStep: state.step),
                      Expanded(child: _stepContent(state)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _stepContent(BookingFlowState state) {
    switch (state.step) {
      case 0:  return _FarmsStep(state: state);
      case 1:  return _VetsStep(state: state);
      case 2:  return _AnimalsStep(state: state);
      case 3:  return const _TypeDateStep();
      case 4:  return _ConfirmStep(state: state);
      default: return const SizedBox.shrink();
    }
  }
}

// ── Step progress dots ─────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: i == currentStep ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i <= currentStep ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.icon,
    required this.message,
    this.onRetry,
    this.showRetry = false,
  });
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontFamily: 'Cairo',
              ),
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing = '',
  });
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing.isNotEmpty) ...[
                Text(
                  trailing,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 0 — Farm selection ────────────────────────────────────────────────

class _FarmsStep extends StatelessWidget {
  const _FarmsStep({required this.state});
  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.farms.isEmpty) {
      return _EmptyView(
        icon: Icons.agriculture_outlined,
        message: AppStrings.bookNoFarms,
        onRetry: () => context.read<BookingCubit>().loadFarms(),
        showRetry: state.error != null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: state.farms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final farm = state.farms[i];
        return _SelectCard(
          onTap: () => context.read<BookingCubit>().selectFarm(farm),
          icon: Icons.agriculture_outlined,
          title: farm.name,
          subtitle: '${farm.location} — ${farm.regionName}',
          trailing: '${farm.animalCount} حيوانات',
        );
      },
    );
  }
}

// ── Step 1 — Vet selection ─────────────────────────────────────────────────

class _VetsStep extends StatelessWidget {
  const _VetsStep({required this.state});
  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.vets.isEmpty) {
      return _EmptyView(
        icon: Icons.medical_services_outlined,
        message: AppStrings.bookNoVets,
        onRetry: () => context.read<BookingCubit>().retryLoadVets(),
        showRetry: state.error != null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: state.vets.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final vet = state.vets[i];
        return _VetSelectCard(
          vet: vet,
          onSelect: () => context.read<BookingCubit>().selectVet(vet),
          onViewReviews: vet.totalReviews > 0
              ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<ReviewsCubit>(),
                      child: VetReviewsScreen(
                        vetId:         vet.vetId,
                        currentUserId: 0,
                      ),
                    ),
                  ))
              : null,
        );
      },
    );
  }
}

// ── Step 2 — Animal multi-select ───────────────────────────────────────────

class _AnimalsStep extends StatelessWidget {
  const _AnimalsStep({required this.state});
  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.farmAnimals.isEmpty) {
      return _EmptyView(
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
                onTap: () => context.read<BookingCubit>().toggleAnimal(animal.id),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        color: isSelected ? AppColors.primary : AppColors.textLight,
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

// ── Step 3 — Type + Date/Time ──────────────────────────────────────────────

class _TypeDateStep extends StatefulWidget {
  const _TypeDateStep();

  @override
  State<_TypeDateStep> createState() => _TypeDateStepState();
}

class _TypeDateStepState extends State<_TypeDateStep> {
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
                          onTap: () => context.read<BookingCubit>().setBookingType('FarmVisit'),
                        ),
                        const SizedBox(width: 12),
                        _TypeChip(
                          label: AppStrings.bookingTypeOnline,
                          icon: Icons.videocam_outlined,
                          selected: state.bookingType == 'Online',
                          onTap: () => context.read<BookingCubit>().setBookingType('Online'),
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
            Icon(icon, color: hasValue ? AppColors.primary : AppColors.textLight),
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

// ── Step 4 — Confirm + Submit ──────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({required this.state});
  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final vet  = state.selectedVet;
    final farm = state.selectedFarm;
    final date = state.scheduledDate;
    final time = state.scheduledTime;
    if (vet == null || date == null || time == null) return const SizedBox.shrink();

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

// ── Vet selection card with stars + reviews button ────────────────────────

class _VetSelectCard extends StatelessWidget {
  const _VetSelectCard({
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
                  const Icon(Icons.medical_services_outlined,
                      size: 20, color: AppColors.primary),
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
                  RatingStarsWidget(
                    rating: vet.averageRating,
                    size: 16,
                  ),
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
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        AppStrings.reviewsTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
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

// ── Success screen ─────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 24),
          const Text(
            'تم إرسال طلب الحجز بنجاح!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'هيتواصل معاك الدكتور لتأكيد الموعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textMedium,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 40),
          CustomButton(
            label: AppStrings.bookViewOrders,
            onPressed: onDone, // pops with result=true → caller switches to orders tab
          ),
        ],
      ),
    );
  }
}
