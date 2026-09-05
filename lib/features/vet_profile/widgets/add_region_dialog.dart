import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../farms/models/region_model.dart';

class AddRegionDialog extends StatefulWidget {
  const AddRegionDialog({super.key, required this.availableRegions});

  final List<RegionModel> availableRegions;

  static Future<int?> show(
    BuildContext context, {
    required List<RegionModel> availableRegions,
  }) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => AddRegionDialog(availableRegions: availableRegions),
    );
  }

  @override
  State<AddRegionDialog> createState() => _AddRegionDialogState();
}

class _AddRegionDialogState extends State<AddRegionDialog> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.selectRegionToAdd),
      content: DropdownButton<int>(
        value: selected,
        isExpanded: true,
        hint: const Text(AppStrings.selectRegion),
        items: widget.availableRegions
            .map(
              (r) => DropdownMenuItem(value: r.regionId, child: Text(r.name)),
            )
            .toList(),
        onChanged: (v) => setState(() => selected = v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: selected == null
              ? null
              : () => Navigator.pop(context, selected),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
