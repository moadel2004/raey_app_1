import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../cubit/vet_profile_cubit.dart';
import '../models/availability_model.dart';

/// BottomSheet لإضافة أو تعديل ميعاد.
/// [availability] = null → إضافة / non-null → تعديل.
class AvailabilityFormSheet extends StatefulWidget {
  const AvailabilityFormSheet({super.key, this.availability});
  final AvailabilityModel? availability;

  @override
  State<AvailabilityFormSheet> createState() => _AvailabilityFormSheetState();
}

class _AvailabilityFormSheetState extends State<AvailabilityFormSheet> {
  int? _day;
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _isActive = true;

  bool get _isEdit => widget.availability != null;

  @override
  void initState() {
    super.initState();
    final a = widget.availability;
    if (a != null) {
      _day      = a.dayOfWeek;
      _start    = a.startTimeOfDay;
      _end      = a.endTimeOfDay;
      _isActive = a.isActive;
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_start ?? const TimeOfDay(hour: 9, minute: 0))
        : (_end   ?? const TimeOfDay(hour: 17, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? AppStrings.availabilityFrom : AppStrings.availabilityTo,
    );
    if (picked != null && mounted) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  void _submit() {
    if (_day == null) {
      _showError('الرجاء اختيار اليوم');
      return;
    }
    if (_start == null) {
      _showError('الرجاء اختيار وقت البداية');
      return;
    }
    if (_end == null) {
      _showError('الرجاء اختيار وقت النهاية');
      return;
    }
    final startMins = _start!.hour * 60 + _start!.minute;
    final endMins   = _end!.hour   * 60 + _end!.minute;
    if (endMins <= startMins) {
      _showError('وقت النهاية لازم يكون بعد البداية');
      return;
    }

    final startStr = timeOfDayToApi(_start!);
    final endStr   = timeOfDayToApi(_end!);
    final cubit    = context.read<VetProfileCubit>();

    if (_isEdit) {
      cubit.updateAvailability(
        id:        widget.availability!.id,
        dayOfWeek: _day!,
        startTime: startStr,
        endTime:   endStr,
        isActive:  _isActive,
      );
    } else {
      cubit.addAvailability(
        dayOfWeek: _day!,
        startTime: startStr,
        endTime:   endStr,
      );
    }
    Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VetProfileCubit, VetProfileState>(
      builder: (context, state) {
        final isLoading = state is VetActionLoading;
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEdit ? AppStrings.editAvailability : AppStrings.addAvailability,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Day dropdown
              _label(AppStrings.selectDay),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _day,
                hint: const Text(AppStrings.selectDay),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                items: List.generate(
                  kDayNamesAr.length,
                  (i) => DropdownMenuItem(value: i, child: Text(kDayNamesAr[i])),
                ),
                onChanged: (v) => setState(() => _day = v),
              ),
              const SizedBox(height: 16),

              // Time pickers row
              Row(
                children: [
                  Expanded(child: _timeTile(AppStrings.availabilityFrom, _start, () => _pickTime(isStart: true))),
                  const SizedBox(width: 12),
                  Expanded(child: _timeTile(AppStrings.availabilityTo,   _end,   () => _pickTime(isStart: false))),
                ],
              ),
              const SizedBox(height: 16),

              // isActive switch (edit only)
              if (_isEdit)
                Row(
                  children: [
                    const Text(AppStrings.availabilityIsActive,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Switch(
                      value: _isActive,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),
              if (_isEdit) const SizedBox(height: 8),

              CustomButton(
                label: _isEdit ? AppStrings.saveChanges : AppStrings.addAvailability,
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeTile(String label, TimeOfDay? time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 18, color: AppColors.textMedium),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
                Text(
                  time == null
                      ? '--:--'
                      : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: time == null ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
}
