import 'package:flutter/material.dart';

class MedicalPrescriptionTile extends StatelessWidget {
  const MedicalPrescriptionTile({
    super.key,
    required this.index,
    required this.name,
    required this.dosage,
    required this.duration,
  });

  final int index;
  final String name;
  final String dosage;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. $name',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _chip('الجرعة: $dosage'),
              const SizedBox(width: 8),
              _chip('المدة: $duration'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.green.shade300),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 11,
        color: Colors.green.shade700,
      ),
    ),
  );
}
