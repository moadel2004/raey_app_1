import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/medical_cubit.dart';
import '../models/medical_record_model.dart';
import '../models/record_change_model.dart';
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
        .push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<MedicalCubit>(),
            child: MedicalRecordFormScreen(
              vetId:          widget.vetId,
              existingRecord: _record,
            ),
          ),
        ))
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
        title: const Text(
          'حذف السجل',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: const Text(
          'متأكد إنك عايز تحذف السجل الطبي ده؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
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
            return _HistorySheet(changes: state.changes);
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ));
            Navigator.of(context).pop(true);
          } else if (state is MedicalError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
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
                          color: AppColors.primary),
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
        // ── Header chip: visit type ──────────────────────────────────────
        Center(
          child: _VisitTypeChip(visitType: _record.visitType),
        ),
        const SizedBox(height: 20),

        // ── Animal info ──────────────────────────────────────────────────
        _SectionCard(
          title: 'الحيوان',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(label: 'النوع', value: _record.animalType),
              _Row(label: 'الرقم التعريفي', value: _record.animalTagId),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Date ─────────────────────────────────────────────────────────
        _SectionCard(
          title: 'التاريخ',
          child: _Row(
            label: 'تاريخ الكشف',
            value: _formatDate(_record.createdAt),
          ),
        ),
        const SizedBox(height: 12),

        // ── Clinical info ─────────────────────────────────────────────────
        if (_record.symptoms != null || _record.diagnosis != null) ...[
          _SectionCard(
            title: 'التقرير الطبي',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_record.symptoms != null)
                  _Field(
                    label: AppStrings.medicalSymptoms,
                    value: _record.symptoms!,
                  ),
                if (_record.diagnosis != null) ...[
                  if (_record.symptoms != null)
                    const Divider(height: 20),
                  _Field(
                    label: AppStrings.medicalDiagnosis,
                    value: _record.diagnosis!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Notes ─────────────────────────────────────────────────────────
        if (_record.notes != null) ...[
          _SectionCard(
            title: AppStrings.medicalNotes,
            child: Text(
              _record.notes!,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Prescriptions ─────────────────────────────────────────────────
        _SectionCard(
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
                  children: List.generate(
                    _record.prescriptions.length,
                    (i) {
                      final p = _record.prescriptions[i];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i < _record.prescriptions.length - 1 ? 12 : 0,
                        ),
                        child: _PrescriptionTile(
                          index: i + 1,
                          name: p.medicationName,
                          dosage: p.dosage,
                          duration: p.duration,
                        ),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

// ── Reusable widgets ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
      ],
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  const _PrescriptionTile({
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
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

class _VisitTypeChip extends StatelessWidget {
  const _VisitTypeChip({required this.visitType});

  final String visitType;

  String get _label {
    switch (visitType) {
      case 'Examination': return AppStrings.visitTypeExamination;
      case 'FollowUp':    return AppStrings.visitTypeFollowUp;
      case 'Emergency':   return AppStrings.visitTypeEmergency;
      case 'Vaccination': return AppStrings.visitTypeVaccination;
      default:            return visitType;
    }
  }

  Color get _color {
    switch (visitType) {
      case 'Emergency':   return Colors.red;
      case 'Examination': return Colors.blue;
      case 'FollowUp':    return Colors.orange;
      case 'Vaccination': return Colors.green;
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({required this.changes});

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
