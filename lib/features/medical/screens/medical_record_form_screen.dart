import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../orders/models/booking_model.dart';
import '../cubit/medical_cubit.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';

/// Form for creating OR editing a medical record.
///
/// Create mode: pass [bookingId] + [animals] + [vetId].
/// Edit mode: pass [existingRecord] + [vetId] (bookingId/animals ignored).
class MedicalRecordFormScreen extends StatefulWidget {
  const MedicalRecordFormScreen({
    super.key,
    required this.vetId,
    this.bookingId = 0,
    this.animals = const [],
    this.existingRecord,
  });

  final int vetId;
  final int bookingId;
  final List<BookingAnimal> animals;
  final MedicalRecordModel? existingRecord;

  bool get isEdit => existingRecord != null;

  @override
  State<MedicalRecordFormScreen> createState() =>
      _MedicalRecordFormScreenState();
}

class _PrescriptionRow {
  _PrescriptionRow({String name = '', String dosage = '', String duration = ''})
      : nameCtrl     = TextEditingController(text: name),
        dosageCtrl   = TextEditingController(text: dosage),
        durationCtrl = TextEditingController(text: duration);

  final TextEditingController nameCtrl;
  final TextEditingController dosageCtrl;
  final TextEditingController durationCtrl;

  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    durationCtrl.dispose();
  }

  PrescriptionModel toModel() => PrescriptionModel(
        medicationName: nameCtrl.text.trim(),
        dosage:         dosageCtrl.text.trim(),
        duration:       durationCtrl.text.trim(),
      );
}

class _MedicalRecordFormScreenState extends State<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selected animal (create mode)
  BookingAnimal? _selectedAnimal;

  // Visit type
  static final _visitTypes = [
    ('Examination', AppStrings.visitTypeExamination),
    ('FollowUp',    AppStrings.visitTypeFollowUp),
    ('Emergency',   AppStrings.visitTypeEmergency),
    ('Vaccination', AppStrings.visitTypeVaccination),
  ];
  String _visitType = 'Examination';

  // Optional text fields
  final _symptomsCtrl  = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl     = TextEditingController();

  // Prescriptions
  final List<_PrescriptionRow> _prescriptions = [];

  @override
  void initState() {
    super.initState();

    // Pre-select first animal in create mode
    if (!widget.isEdit && widget.animals.isNotEmpty) {
      _selectedAnimal = widget.animals.first;
    }

    // Pre-fill from existing record in edit mode
    if (widget.isEdit) {
      final r = widget.existingRecord!;
      _visitType = r.visitType;
      _symptomsCtrl.text  = r.symptoms  ?? '';
      _diagnosisCtrl.text = r.diagnosis ?? '';
      _notesCtrl.text     = r.notes     ?? '';
      for (final p in r.prescriptions) {
        _prescriptions.add(_PrescriptionRow(
          name:     p.medicationName,
          dosage:   p.dosage,
          duration: p.duration,
        ));
      }
    }
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    for (final row in _prescriptions) {
      row.dispose();
    }
    super.dispose();
  }

  void _addPrescription() {
    setState(() => _prescriptions.add(_PrescriptionRow()));
  }

  void _removePrescription(int index) {
    setState(() {
      _prescriptions[index].dispose();
      _prescriptions.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<MedicalCubit>();

    // Validate prescriptions — each started row must be complete
    for (int i = 0; i < _prescriptions.length; i++) {
      final row = _prescriptions[i];
      if (row.nameCtrl.text.trim().isEmpty ||
          row.dosageCtrl.text.trim().isEmpty ||
          row.durationCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('أكمل بيانات الدواء ${i + 1} أو احذفه'),
          backgroundColor: AppColors.error,
        ));
        return;
      }
    }

    final prescriptions =
        _prescriptions.map((r) => r.toModel()).toList();

    if (widget.isEdit) {
      await cubit.updateRecord(
        widget.existingRecord!.recordId,
        visitType:     _visitType,
        symptoms:      _symptomsCtrl.text.trim(),
        diagnosis:     _diagnosisCtrl.text.trim(),
        notes:         _notesCtrl.text.trim(),
        prescriptions: prescriptions,
      );
    } else {
      if (_selectedAnimal == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.medicalSelectAnimal),
          backgroundColor: AppColors.error,
        ));
        return;
      }
      await cubit.createRecord(
        animalId:      _selectedAnimal!.animalId,
        vetId:         widget.vetId,
        bookingId:     widget.bookingId,
        visitType:     _visitType,
        symptoms:      _symptomsCtrl.text.trim(),
        diagnosis:     _diagnosisCtrl.text.trim(),
        notes:         _notesCtrl.text.trim(),
        prescriptions: prescriptions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? AppStrings.medicalRecordEdit
              : AppStrings.medicalRecordNew,
        ),
      ),
      body: BlocConsumer<MedicalCubit, MedicalState>(
        listenWhen: (p, c) =>
            c is MedicalActionSuccess || c is MedicalError,
        listener: (context, state) {
          if (state is MedicalActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ));
            Navigator.of(context).pop(true); // signal caller to refresh
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
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Animal selector (create mode only) ──────────────────
                    if (!widget.isEdit) ...[
                      if (widget.animals.isEmpty)
                        _infoCard(AppStrings.medicalNoAnimals)
                      else if (widget.animals.length == 1)
                        _infoCard(
                          '${widget.animals.first.type} — ${widget.animals.first.breed}',
                        )
                      else ...[
                        _label(AppStrings.medicalSelectAnimal),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<BookingAnimal>(
                          value: _selectedAnimal,
                          decoration: _inputDecoration(),
                          isExpanded: true,
                          items: widget.animals.map((a) {
                            return DropdownMenuItem(
                              value: a,
                              child: Text(
                                '${a.type} — ${a.breed}',
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedAnimal = v),
                          validator: (v) =>
                              v == null ? AppStrings.requiredField : null,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],

                    // ── Visit type ───────────────────────────────────────────
                    _label(AppStrings.visitTypeLabel),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _visitType,
                      decoration: _inputDecoration(),
                      items: _visitTypes.map((t) {
                        return DropdownMenuItem(
                          value: t.$1,
                          child: Text(
                            t.$2,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _visitType = v ?? _visitType),
                    ),
                    const SizedBox(height: 20),

                    // ── Symptoms ─────────────────────────────────────────────
                    _label(AppStrings.medicalSymptoms),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _symptomsCtrl,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      decoration: _inputDecoration(
                        hint: AppStrings.medicalSymptomsHint,
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 20),

                    // ── Diagnosis ────────────────────────────────────────────
                    _label(AppStrings.medicalDiagnosis),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _diagnosisCtrl,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      decoration: _inputDecoration(
                        hint: AppStrings.medicalDiagnosisHint,
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 20),

                    // ── Notes ────────────────────────────────────────────────
                    _label(AppStrings.medicalNotes),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      decoration: _inputDecoration(
                        hint: AppStrings.medicalNotesHint,
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 28),

                    // ── Prescriptions header ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.medicalPrescriptions,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addPrescription,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            AppStrings.medicalAddPrescription,
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),

                    // ── Prescription rows ─────────────────────────────────────
                    ...List.generate(_prescriptions.length, (i) {
                      final row = _prescriptions[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'دواء ${i + 1}',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      onPressed: () => _removePrescription(i),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: row.nameCtrl,
                                  textDirection: TextDirection.rtl,
                                  decoration: _inputDecoration(
                                    hint: AppStrings.medicalMedName,
                                  ),
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: row.dosageCtrl,
                                        textDirection: TextDirection.rtl,
                                        decoration: _inputDecoration(
                                          hint: AppStrings.medicalDosage,
                                        ),
                                        style: const TextStyle(
                                            fontFamily: 'Cairo'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: row.durationCtrl,
                                        textDirection: TextDirection.rtl,
                                        decoration: _inputDecoration(
                                          hint: AppStrings.medicalDuration,
                                        ),
                                        style: const TextStyle(
                                            fontFamily: 'Cairo'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    // ── Submit ────────────────────────────────────────────────
                    CustomButton(
                      label: widget.isEdit
                          ? AppStrings.medicalRecordEdit
                          : AppStrings.medicalRecordNew,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(color: Colors.transparent),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _infoCard(String text) => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
      );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Cairo',
          color: Colors.grey.shade400,
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      );
}
