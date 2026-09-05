import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../farms/models/region_model.dart';
import '../cubit/vet_profile_cubit.dart';
import '../models/availability_model.dart';
import '../widgets/add_region_dialog.dart';
import '../widgets/availability_form_sheet.dart';
import '../widgets/vet_availability_section.dart';
import '../widgets/vet_info_section.dart';
import '../widgets/vet_profile_form_section.dart';
import '../widgets/vet_regions_section.dart';

class VetProfileScreen extends StatefulWidget {
  const VetProfileScreen({super.key});

  @override
  State<VetProfileScreen> createState() => _VetProfileScreenState();
}

class _VetProfileScreenState extends State<VetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  bool _profileSynced = false;

  @override
  void dispose() {
    _bioCtrl.dispose();
    _expCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  void _syncControllers(VetProfileLoaded loaded) {
    if (_profileSynced) return;
    _bioCtrl.text = loaded.profile.bio ?? '';
    _expCtrl.text = loaded.profile.experienceYears.toString();
    _feeCtrl.text = loaded.profile.consultationFee.toStringAsFixed(0);
    _profileSynced = true;
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    context.read<VetProfileCubit>().updateProfile(
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      experienceYears: int.tryParse(_expCtrl.text.trim()) ?? 0,
      consultationFee: double.tryParse(_feeCtrl.text.trim()) ?? 0,
    );
  }

  Future<void> _confirmRemoveRegion(RegionModel r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r.name),
        content: const Text(AppStrings.removeRegionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<VetProfileCubit>().removeRegion(r.regionId);
    }
  }

  Future<void> _showAddRegionDialog(VetProfileLoaded loaded) async {
    final current = loaded.profile.regions.map((r) => r.regionId).toSet();
    final available = loaded.allRegions
        .where((r) => !current.contains(r.regionId))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أنت بالفعل في كل المناطق')));
      return;
    }

    final selectedRegionId = await AddRegionDialog.show(
      context,
      availableRegions: available,
    );

    if (selectedRegionId != null && mounted) {
      context.read<VetProfileCubit>().addRegion(selectedRegionId);
    }
  }

  void _showAvailabilitySheet({AvailabilityModel? avail}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<VetProfileCubit>(),
        child: AvailabilityFormSheet(availability: avail),
      ),
    );
  }

  Future<void> _confirmDeleteAvailability(AvailabilityModel a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(a.dayNameAr),
        content: const Text(AppStrings.deleteAvailabilityConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<VetProfileCubit>().deleteAvailability(a.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.vetProfileTitle),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: BlocConsumer<VetProfileCubit, VetProfileState>(
        listener: (context, state) {
          if (state is VetActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            _profileSynced = false;
          }
          if (state is VetProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<VetProfileCubit>();
          final loaded = state is VetProfileLoaded ? state : cubit.cached;
          final isAction = state is VetActionLoading;

          // Initial full-screen loading
          if (state is VetProfileLoading && loaded == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Full-screen error (only if no data to show)
          if (state is VetProfileError && loaded == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_outlined,
                      size: 56,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => cubit.loadAll(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('حاول تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (loaded == null) return const SizedBox.shrink();

          _syncControllers(loaded);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VetInfoSection(loaded: loaded),
                const SizedBox(height: 20),
                VetProfileFormSection(
                  formKey: _formKey,
                  bioCtrl: _bioCtrl,
                  expCtrl: _expCtrl,
                  feeCtrl: _feeCtrl,
                  isLoading: isAction,
                  onSave: _saveProfile,
                ),
                const SizedBox(height: 20),
                VetRegionsSection(
                  loaded: loaded,
                  isLoading: isAction,
                  onAdd: () => _showAddRegionDialog(loaded),
                  onRemove: _confirmRemoveRegion,
                ),
                const SizedBox(height: 20),
                VetAvailabilitySection(
                  loaded: loaded,
                  isLoading: isAction,
                  onAdd: () => _showAvailabilitySheet(),
                  onEdit: (a) => _showAvailabilitySheet(avail: a),
                  onDelete: _confirmDeleteAvailability,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
