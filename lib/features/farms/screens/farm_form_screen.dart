import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../cubit/farms_cubit.dart';
import '../models/farm_model.dart';
import '../models/region_model.dart';

class FarmFormScreen extends StatefulWidget {
  /// null → إضافة جديدة / non-null → تعديل
  final FarmModel? farm;
  const FarmFormScreen({super.key, this.farm});

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey      = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;

  List<RegionModel> _regions = [];
  int? _selectedRegionId;
  bool _loadingRegions = true;

  bool get _isEdit => widget.farm != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl     = TextEditingController(text: widget.farm?.name     ?? '');
    _locationCtrl = TextEditingController(text: widget.farm?.location ?? '');

    // استخدم الـ regions المحمّلة مسبقاً في الـ cubit
    _loadCachedRegions();
  }

  void _loadCachedRegions() {
    final cubit = context.read<FarmsCubit>();
    final cached = cubit.regions;
    if (cached.isNotEmpty) {
      setState(() {
        _regions = cached;
        _selectedRegionId = widget.farm?.regionId;
        _loadingRegions = false;
      });
    } else {
      cubit.loadRegions().then((_) {
        if (!mounted) return;
        setState(() {
          _regions = cubit.regions;
          _selectedRegionId = widget.farm?.regionId;
          _loadingRegions = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المحافظة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cubit = context.read<FarmsCubit>();
    if (_isEdit) {
      cubit.updateFarm(
        id:       widget.farm!.id,
        name:     _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        regionId: _selectedRegionId!,
      );
    } else {
      cubit.createFarm(
        name:     _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        regionId: _selectedRegionId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? AppStrings.editFarm : AppStrings.addFarm),
      ),
      body: BlocListener<FarmsCubit, FarmsState>(
        listener: (context, state) {
          if (state is FarmActionSuccess) {
            context.pop();
          } else if (state is FarmsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<FarmsCubit, FarmsState>(
          builder: (context, state) {
            final isLoading = state is FarmActionLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المزرعة
                    _label(AppStrings.farmName),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: AppStrings.farmNameHint,
                        prefixIcon: const Icon(Icons.agriculture_outlined),
                      ),
                      maxLength: 200,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                          null,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return AppStrings.requiredField;
                        if (v.trim().length > 200) return 'الحد الأقصى 200 حرف';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // الموقع
                    _label(AppStrings.farmLocation),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: InputDecoration(
                        hintText: AppStrings.farmLocationHint,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      maxLength: 300,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                          null,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return AppStrings.requiredField;
                        if (v.trim().length > 300) return 'الحد الأقصى 300 حرف';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // المحافظة
                    _label(AppStrings.farmRegion),
                    const SizedBox(height: 8),
                    _loadingRegions
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          )
                        : DropdownButtonFormField<int>(
                            value: _selectedRegionId,
                            hint: const Text(AppStrings.selectRegion),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                            items: _regions
                                .map((r) => DropdownMenuItem(
                                      value: r.regionId,
                                      child: Text(r.name),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedRegionId = v),
                          ),
                    const SizedBox(height: 40),

                    CustomButton(
                      label: _isEdit ? AppStrings.editFarm : AppStrings.addFarm,
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
