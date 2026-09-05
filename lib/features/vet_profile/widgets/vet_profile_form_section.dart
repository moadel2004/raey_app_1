import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import 'vet_card_container.dart';

class VetProfileFormSection extends StatelessWidget {
  const VetProfileFormSection({
    super.key,
    required this.formKey,
    required this.bioCtrl,
    required this.expCtrl,
    required this.feeCtrl,
    required this.isLoading,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController bioCtrl;
  final TextEditingController expCtrl;
  final TextEditingController feeCtrl;
  final bool isLoading;
  final VoidCallback onSave;

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textMedium,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return VetCardContainer(
      title: AppStrings.vetProfileTitle,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(AppStrings.vetBio),
            const SizedBox(height: 8),
            TextFormField(
              controller: bioCtrl,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: AppStrings.vetBioHint,
                counterStyle: TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(AppStrings.vetExperienceYears),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: expCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.work_history_outlined),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 0 || n > 60) {
                            return '0–60 سنة';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(AppStrings.vetConsultationFee),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: feeCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 0) return 'رقم صحيح';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: AppStrings.saveChanges,
              isLoading: isLoading,
              onPressed: isLoading ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}
