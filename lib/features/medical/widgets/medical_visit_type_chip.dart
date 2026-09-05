import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class MedicalVisitTypeChip extends StatelessWidget {
  const MedicalVisitTypeChip({super.key, required this.visitType});

  final String visitType;

  String get _label {
    switch (visitType) {
      case 'Examination':
        return AppStrings.visitTypeExamination;
      case 'FollowUp':
        return AppStrings.visitTypeFollowUp;
      case 'Emergency':
        return AppStrings.visitTypeEmergency;
      case 'Vaccination':
        return AppStrings.visitTypeVaccination;
      default:
        return visitType;
    }
  }

  Color get _color {
    switch (visitType) {
      case 'Emergency':
        return Colors.red;
      case 'Examination':
        return Colors.blue;
      case 'FollowUp':
        return Colors.orange;
      case 'Vaccination':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: _color,
        ),
      ),
    );
  }
}
