import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/medical_cubit.dart';
import '../models/medical_record_model.dart';
import '../widgets/medical_history_sheet.dart';
import '../widgets/medical_prescription_tile.dart';
import '../widgets/medical_section_card.dart';
import '../widgets/medical_visit_type_chip.dart';
import 'medical_record_form_screen.dart';

class MedicalRecordDetailsScreen extends StatefulWidget {
  const MedicalRecordDetailsScreen({
    super.key,
    required this.record,
    required this.isVet,
    required this.vetId,
  });

  final MedicalRecordModel record;
  final bool isVet;
  final int vetId;

  @override
  State<MedicalRecordDetailsScreen> createState() =>
      _MedicalRecordDetailsScreenState();
}

class _MedicalRecordDetailsScreenState
    extends State<MedicalRecordDetailsScreen> {
  late MedicalRecordModel _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  void _openEdit() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<MedicalCubit>(),
              child: MedicalRecordFormScreen(
                vetId: widget.vetId,
                existingRecord: _record,
              ),
            ),
          ),
        )
        .then((refreshed) {
          if (refreshed == true && mounted) {
            context.read<MedicalCubit>().loadRecord(_record.recordId);
          }
        });
  }

  void _confirmDelete() {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف السجل', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(
          'متأكد إنك عايز تحذف السجل الطبي ده؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<MedicalCubit>().deleteRecord(_record.recordId);
      }
    });
  }

  void _showHistory() {
    context.read<MedicalCubit>().loadRecordChanges(_record.recordId);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocBuilder<MedicalCubit, MedicalState>(
        bloc: context.read<MedicalCubit>(),
        builder: (context, state) {
          if (state is MedicalLoading) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          if (state is RecordChangesLoaded) {
            return MedicalHistorySheet(changes: state.changes);
          }
          if (state is MedicalError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            );
          }
          return const SizedBox(height: 200);
        },
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.medicalRecordDetails),
        actions: [
          if (widget.isVet) ...[
            IconButton(
              icon: const Icon(Icons.history_outlined),
              tooltip: AppStrings.medicalRecordHistory,
              onPressed: _showHistory,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: AppStrings.medicalRecordEdit,
              onPressed: _openEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'حذف',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: BlocConsumer<MedicalCubit, MedicalState>(
        listenWhen: (p, c) =>
            c is MedicalRecordLoaded ||
            c is MedicalActionSuccess ||
            c is MedicalError,
        listener: (context, state) {
          if (state is MedicalRecordLoaded) {
            setState(() => _record = state.record);
          } else if (state is MedicalActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is MedicalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is MedicalActionLoading;
          return Stack(
            children: [
              _buildBody(),
              if (isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x55000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: MedicalVisitTypeChip(visitType: _record.visitType)),
        const SizedBox(height: 20),
        MedicalSectionCard(
          title: 'الحيوان',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicalDetailRow(label: 'النوع', value: _record.animalType),
              MedicalDetailRow(
                label: 'الرقم التعريفي',
                value: _record.animalTagId,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MedicalSectionCard(
          title: 'التاريخ',
          child: MedicalDetailRow(
            label: 'تاريخ الكشف',
            value: _formatDate(_record.createdAt),
          ),
        ),
        const SizedBox(height: 12),
        if (_record.symptoms != null || _record.diagnosis != null) ...[
          MedicalSectionCard(
            title: 'التقرير الطبي',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_record.symptoms != null)
                  MedicalDetailField(
                    label: AppStrings.medicalSymptoms,
                    value: _record.symptoms!,
                  ),
                if (_record.diagnosis != null) ...[
                  if (_record.symptoms != null) const Divider(height: 20),
                  MedicalDetailField(
                    label: AppStrings.medicalDiagnosis,
                    value: _record.diagnosis!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_record.notes != null) ...[
          MedicalSectionCard(
            title: AppStrings.medicalNotes,
            child: Text(
              _record.notes!,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],
        MedicalSectionCard(
          title: AppStrings.medicalPrescriptions,
          child: _record.prescriptions.isEmpty
              ? const Text(
                  'لا توجد أدوية مسجلة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                )
              : Column(
                  children: List.generate(_record.prescriptions.length, (i) {
                    final p = _record.prescriptions[i];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i < _record.prescriptions.length - 1 ? 12 : 0,
                      ),
                      child: MedicalPrescriptionTile(
                        index: i + 1,
                        name: p.medicationName,
                        dosage: p.dosage,
                        duration: p.duration,
                      ),
                    );
                  }),
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
