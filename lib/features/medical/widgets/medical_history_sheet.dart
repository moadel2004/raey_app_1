import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../models/record_change_model.dart';

class MedicalHistorySheet extends StatelessWidget {
  const MedicalHistorySheet({super.key, required this.changes});

  final List<RecordChangeModel> changes;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.medicalRecordHistory,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: changes.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.medicalChangesEmpty,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: changes.length,
                    separatorBuilder: (_, i) => const Divider(height: 16),
                    itemBuilder: (_, i) => _ChangeEntry(change: changes[i]),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ChangeEntry extends StatelessWidget {
  const _ChangeEntry({required this.change});

  final RecordChangeModel change;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              change.modifiedBy,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${change.modifiedAt.day}/${change.modifiedAt.month}/${change.modifiedAt.year}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        if (change.previousDiagnosis != null) ...[
          const SizedBox(height: 4),
          Text(
            'تشخيص سابق: ${change.previousDiagnosis}',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        if (change.previousNotes != null) ...[
          const SizedBox(height: 2),
          Text(
            'ملاحظات سابقة: ${change.previousNotes}',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
