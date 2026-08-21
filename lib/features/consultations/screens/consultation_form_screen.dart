import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../booking/models/vet_summary_model.dart';
import '../cubit/consultations_cubit.dart';

class ConsultationFormScreen extends StatefulWidget {
  const ConsultationFormScreen({super.key});

  @override
  State<ConsultationFormScreen> createState() => _ConsultationFormScreenState();
}

class _ConsultationFormScreenState extends State<ConsultationFormScreen> {
  // step 0 = اختار دكتور | step 1 = موضوع + تفاصيل
  int _step = 0;

  List<VetSummaryModel> _vets = [];
  bool _vetsLoading = false;
  String? _vetsError;
  VetSummaryModel? _selectedVet;

  final _subjectCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _formKey     = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadVets();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVets() async {
    setState(() { _vetsLoading = true; _vetsError = null; });
    try {
      final vets = await context.read<ConsultationsCubit>().getAllVets();
      if (mounted) setState(() { _vets = vets; _vetsLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _vetsLoading = false; _vetsError = e.message; });
    } catch (_) {
      if (mounted) setState(() { _vetsLoading = false; _vetsError = AppStrings.unknownError; });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ConsultationsCubit>().createConsultation(
      veterinarianId: _selectedVet!.vetId,
      subject:        _subjectCtrl.text.trim(),
      description:    _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.consultationOnline),
        leading: BackButton(
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: BlocConsumer<ConsultationsCubit, ConsultationsState>(
        listener: (context, state) {
          if (state is ConsultationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ));
            Navigator.of(context).pop(true);
          }
          if (state is ConsultationsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is ConsultationActionLoading;
          return _step == 0
              ? _buildSelectVetStep()
              : _buildFormStep(isSubmitting);
        },
      ),
    );
  }

  // ── Step 0: اختار الدكتور ─────────────────────────────────────────────────

  Widget _buildSelectVetStep() {
    if (_vetsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_vetsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_vetsError!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadVets,
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
              ),
            ],
          ),
        ),
      );
    }
    if (_vets.isEmpty) {
      return const Center(
        child: Text('مفيش دكاترة متاحين حالياً',
            style: TextStyle(color: AppColors.textMedium, fontFamily: 'Cairo')),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vets.length,
      itemBuilder: (_, i) {
        final vet = _vets[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primarySurface,
              child: Icon(Icons.medical_services_outlined, color: AppColors.primary),
            ),
            title: Text(vet.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
            subtitle: Text(
              '${vet.experienceYears} سنة خبرة  •  ${vet.consultationFee.toStringAsFixed(0)} ج',
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
            onTap: () => setState(() { _selectedVet = vet; _step = 1; }),
          ),
        );
      },
    );
  }

  // ── Step 1: الموضوع والتفاصيل ─────────────────────────────────────────────

  Widget _buildFormStep(bool isSubmitting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected vet chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_selectedVet!.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Cairo')),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('تغيير',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _label(AppStrings.consultationSubject),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: AppStrings.consultationSubjectHint,
                prefixIcon: const Icon(Icons.chat_bubble_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 16),

            _label(AppStrings.consultationDescription),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: AppStrings.consultationDescHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              label: AppStrings.consultationSubmit,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textDark, fontFamily: 'Cairo'));
}
