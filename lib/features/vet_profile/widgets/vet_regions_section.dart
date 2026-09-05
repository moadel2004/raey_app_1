import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../farms/models/region_model.dart';
import '../cubit/vet_profile_cubit.dart';
import 'vet_card_container.dart';

class VetRegionsSection extends StatelessWidget {
  const VetRegionsSection({
    super.key,
    required this.loaded,
    required this.isLoading,
    required this.onAdd,
    required this.onRemove,
  });

  final VetProfileLoaded loaded;
  final bool isLoading;
  final VoidCallback onAdd;
  final void Function(RegionModel) onRemove;

  @override
  Widget build(BuildContext context) {
    final regions = loaded.profile.regions;
    return VetCardContainer(
      title: AppStrings.vetMyRegions,
      trailing: TextButton.icon(
        onPressed: isLoading ? null : onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text(AppStrings.addRegion),
      ),
      child: regions.isEmpty
          ? const Text(
              'لم تضف أي منطقة بعد',
              style: TextStyle(color: AppColors.textMedium),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: regions
                  .map(
                    (r) => Chip(
                      label: Text(r.name),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: isLoading ? null : () => onRemove(r),
                      backgroundColor: AppColors.primarySurface,
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
