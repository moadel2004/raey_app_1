import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/vet_profile_cubit.dart';
import '../models/availability_model.dart';
import 'vet_card_container.dart';

class VetAvailabilitySection extends StatelessWidget {
  const VetAvailabilitySection({
    super.key,
    required this.loaded,
    required this.isLoading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final VetProfileLoaded loaded;
  final bool isLoading;
  final VoidCallback onAdd;
  final void Function(AvailabilityModel) onEdit;
  final void Function(AvailabilityModel) onDelete;

  @override
  Widget build(BuildContext context) {
    final avails = loaded.availabilities;
    return VetCardContainer(
      title: AppStrings.vetMyAvailability,
      trailing: TextButton.icon(
        onPressed: isLoading ? null : onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text(AppStrings.addAvailability),
      ),
      child: avails.isEmpty
          ? const Text(
              'لم تضف أي مواعيد بعد',
              style: TextStyle(color: AppColors.textMedium),
            )
          : Column(
              children: avails
                  .map(
                    (a) => _AvailabilityTile(
                      avail: a,
                      isLoading: isLoading,
                      onEdit: () => onEdit(a),
                      onDelete: () => onDelete(a),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _AvailabilityTile extends StatelessWidget {
  const _AvailabilityTile({
    required this.avail,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  final AvailabilityModel avail;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
        color: avail.isActive ? AppColors.primarySurface : Colors.grey.shade100,
      ),
      child: ListTile(
        leading: const Icon(Icons.schedule, color: AppColors.primary),
        title: Text(
          avail.dayNameAr,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${formatTimeDisplay(avail.startTime)} ← ${formatTimeDisplay(avail.endTime)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!avail.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'غير مفعّل',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              onPressed: isLoading ? null : onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: AppColors.error,
              ),
              onPressed: isLoading ? null : onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
