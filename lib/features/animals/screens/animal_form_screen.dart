import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../cubit/animals_cubit.dart';
import '../models/animal_model.dart';

class AnimalFormScreen extends StatefulWidget {
  /// null → إضافة / non-null → تعديل
  final AnimalModel? animal;
  final int farmId;

  const AnimalFormScreen({super.key, this.animal, required this.farmId});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey     = GlobalKey<FormState>();
  late final TextEditingController _tagCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _breedCtrl;

  String? _gender;
  DateTime? _birthDate;

  bool get _isEdit => widget.animal != null;

  static const _genderOptions = [
    (label: AppStrings.animalGenderMale,    value: 'Male'),
    (label: AppStrings.animalGenderFemale,  value: 'Female'),
    (label: AppStrings.animalGenderUnknown, value: 'Unknown'),
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _tagCtrl   = TextEditingController(text: a?.officialTagId ?? '');
    _typeCtrl  = TextEditingController(text: a?.type          ?? '');
    _breedCtrl = TextEditingController(text: a?.breed         ?? '');

    // دفاعي: قيمة غير معروفة (زي "أنثى" القديمة) → تقع على Unknown
    if (a != null) {
      _gender    = const {'Male', 'Female', 'Unknown'}.contains(a.gender)
          ? a.gender
          : 'Unknown';
      _birthDate = a.birthDate;
    }
  }

  @override
  void dispose() {
    _tagCtrl.dispose();
    _typeCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'تاريخ الميلاد',
    );
    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار الجنس'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cubit = context.read<AnimalsCubit>();
    if (_isEdit) {
      cubit.updateAnimal(
        id:        widget.animal!.id,
        type:      _typeCtrl.text.trim(),
        breed:     _breedCtrl.text.trim(),
        gender:    _gender!,
        birthDate: _birthDate,
      );
    } else {
      cubit.createAnimal(
        officialTagId: _tagCtrl.text.trim(),
        type:          _typeCtrl.text.trim(),
        breed:         _breedCtrl.text.trim(),
        gender:        _gender!,
        birthDate:     _birthDate,
        farmId:        widget.farmId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? AppStrings.editAnimal : AppStrings.addAnimal),
      ),
      body: BlocListener<AnimalsCubit, AnimalsState>(
        listener: (context, state) {
          if (state is AnimalActionSuccess) {
            Navigator.of(context).pop();
          } else if (state is AnimalsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<AnimalsCubit, AnimalsState>(
          builder: (context, state) {
            final isLoading = state is AnimalActionLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رقم التاج — في التعديل: read-only
                    if (!_isEdit) ...[
                      _label(AppStrings.animalTagId),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tagCtrl,
                        decoration: const InputDecoration(
                          hintText: AppStrings.animalTagIdHint,
                          prefixIcon: Icon(Icons.tag),
                        ),
                        maxLength: 50,
                        buildCounter: (_, {required currentLength,
                            required isFocused, maxLength}) => null,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (v.trim().length > 50) return 'الحد الأقصى 50 حرف';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      _label(AppStrings.animalTagId),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          widget.animal!.officialTagId,
                          style: const TextStyle(
                              color: AppColors.textMedium, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // النوع
                    _label(AppStrings.animalType),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _typeCtrl,
                      decoration: const InputDecoration(
                        hintText: AppStrings.animalTypeHint,
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      maxLength: 50,
                      buildCounter: (_, {required currentLength,
                          required isFocused, maxLength}) => null,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppStrings.requiredField;
                        }
                        if (v.trim().length > 50) return 'الحد الأقصى 50 حرف';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // السلالة
                    _label(AppStrings.animalBreed),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _breedCtrl,
                      decoration: const InputDecoration(
                        hintText: AppStrings.animalBreedHint,
                        prefixIcon: Icon(Icons.edit_note_outlined),
                      ),
                      maxLength: 100,
                      buildCounter: (_, {required currentLength,
                          required isFocused, maxLength}) => null,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppStrings.requiredField;
                        }
                        if (v.trim().length > 100) return 'الحد الأقصى 100 حرف';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // الجنس
                    _label(AppStrings.animalGender),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      hint: const Text(AppStrings.selectGender),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.wc_outlined),
                      ),
                      items: _genderOptions
                          .map((o) => DropdownMenuItem(
                                value: o.value,
                                child: Text(o.label),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 20),

                    // تاريخ الميلاد (اختياري)
                    _label(AppStrings.animalBirthDate),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined,
                                color: AppColors.textMedium, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _birthDate == null
                                  ? 'اختار تاريخ الميلاد'
                                  : '${_birthDate!.day.toString().padLeft(2, '0')}/'
                                      '${_birthDate!.month.toString().padLeft(2, '0')}/'
                                      '${_birthDate!.year}',
                              style: TextStyle(
                                color: _birthDate == null
                                    ? AppColors.textMedium
                                    : AppColors.textDark,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            if (_birthDate != null)
                              GestureDetector(
                                onTap: () => setState(() => _birthDate = null),
                                child: const Icon(Icons.close,
                                    size: 18, color: AppColors.textMedium),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    CustomButton(
                      label: _isEdit ? AppStrings.editAnimal : AppStrings.addAnimal,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      );
}
