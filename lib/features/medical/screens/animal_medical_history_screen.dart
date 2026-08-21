import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/medical_cubit.dart';
import '../models/animal_medical_history_model.dart';
import '../models/prescription_model.dart';

/// Shows the full medical history for a single animal.
/// Works for both farmers and vets — no role-specific actions here.
class AnimalMedicalHistoryScreen extends StatefulWidget {
  const AnimalMedicalHistoryScreen({
    super.key,
    required this.animalId,
    required this.animalLabel, // e.g. "بقرة — A123"
  });

  final int animalId;
  final String animalLabel;

  @override
  State<AnimalMedicalHistoryScreen> createState() =>
      _AnimalMedicalHistoryScreenState();
}

class _AnimalMedicalHistoryScreenState
    extends State<AnimalMedicalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MedicalCubit>().loadAnimalHistory(widget.animalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.animalLabel),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(28),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              AppStrings.medicalHistoryTitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<MedicalCubit, MedicalState>(
        builder: (context, state) {
          if (state is MedicalLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is MedicalError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_outlined,
                        size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<MedicalCubit>()
                          .loadAnimalHistory(widget.animalId),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'حاول تاني',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AnimalHistoryLoaded) {
            final history = state.history;
            if (history.records.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'لسه مفيش سجلات طبية للحيوان ده',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'هتظهر هنا بعد أول كشف',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => context
                  .read<MedicalCubit>()
                  .loadAnimalHistory(widget.animalId),
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.records.length,
                separatorBuilder: (_, i) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final record = history.records[i];
                  return _HistoryCard(record: record);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record});

  final AnimalRecordSummary record;

  String get _visitTypeAr {
    switch (record.visitType) {
      case 'Examination': return AppStrings.visitTypeExamination;
      case 'FollowUp':    return AppStrings.visitTypeFollowUp;
      case 'Emergency':   return AppStrings.visitTypeEmergency;
      case 'Vaccination': return AppStrings.visitTypeVaccination;
      default:            return record.visitType;
    }
  }

  Color get _visitColor {
    switch (record.visitType) {
      case 'Emergency':   return Colors.red;
      case 'Examination': return Colors.blue;
      case 'FollowUp':    return Colors.orange;
      case 'Vaccination': return Colors.green;
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: visit type + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _VisitChip(label: _visitTypeAr, color: _visitColor),
                Text(
                  '${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Vet name
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  record.veterinarianName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Symptoms
            if (record.symptoms != null) ...[
              const SizedBox(height: 10),
              _FieldBlock(
                label: AppStrings.medicalSymptoms,
                value: record.symptoms!,
              ),
            ],

            // Diagnosis
            if (record.diagnosis != null) ...[
              const SizedBox(height: 8),
              _FieldBlock(
                label: AppStrings.medicalDiagnosis,
                value: record.diagnosis!,
              ),
            ],

            // Prescriptions
            if (record.prescriptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                AppStrings.medicalPrescriptions,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              ...record.prescriptions.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _PrescriptionLine(prescription: p),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VisitChip extends StatelessWidget {
  const _VisitChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
        ),
      ],
    );
  }
}

class _PrescriptionLine extends StatelessWidget {
  const _PrescriptionLine({required this.prescription});

  final PrescriptionModel prescription;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.medication_outlined, size: 14, color: Colors.green),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${prescription.medicationName}  —  ${prescription.dosage}  —  ${prescription.duration}',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
