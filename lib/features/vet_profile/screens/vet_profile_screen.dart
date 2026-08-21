import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../farms/models/region_model.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/rating_stars_widget.dart';
import '../../reviews/cubit/reviews_cubit.dart';
import '../../reviews/screens/vet_reviews_screen.dart';
import '../cubit/vet_profile_cubit.dart';
import '../models/availability_model.dart';
import '../widgets/availability_form_sheet.dart';

class VetProfileScreen extends StatefulWidget {
  const VetProfileScreen({super.key});

  @override
  State<VetProfileScreen> createState() => _VetProfileScreenState();
}

class _VetProfileScreenState extends State<VetProfileScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _bioCtrl   = TextEditingController();
  final _expCtrl   = TextEditingController();
  final _feeCtrl   = TextEditingController();
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
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('إزالة')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أنت بالفعل في كل المناطق')),
      );
      return;
    }

    int? selected;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text(AppStrings.selectRegionToAdd),
          content: DropdownButton<int>(
            value: selected,
            isExpanded: true,
            hint: const Text(AppStrings.selectRegion),
            items: available
                .map((r) => DropdownMenuItem(value: r.regionId, child: Text(r.name)))
                .toList(),
            onChanged: (v) => setS(() => selected = v),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: selected == null
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      context.read<VetProfileCubit>().addRegion(selected!);
                    },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
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
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('حذف')),
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
          final cubit   = context.read<VetProfileCubit>();
          final loaded  = state is VetProfileLoaded ? state : cubit.cached;
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
                    const Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 15)),
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
                _InfoSection(loaded: loaded),
                const SizedBox(height: 20),
                _ProfileFormSection(
                  formKey: _formKey,
                  bioCtrl: _bioCtrl,
                  expCtrl: _expCtrl,
                  feeCtrl: _feeCtrl,
                  isLoading: isAction,
                  onSave: _saveProfile,
                ),
                const SizedBox(height: 20),
                _RegionsSection(
                  loaded: loaded,
                  isLoading: isAction,
                  onAdd: () => _showAddRegionDialog(loaded),
                  onRemove: _confirmRemoveRegion,
                ),
                const SizedBox(height: 20),
                _AvailabilitySection(
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

// ── Section: معلوماتي ────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.loaded});
  final VetProfileLoaded loaded;

  @override
  Widget build(BuildContext context) {
    final p = loaded.profile;
    return _Card(
      title: AppStrings.vetMyInfo,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primarySurface,
                child: Icon(Icons.medical_services, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.fullName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(p.phoneNumber,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMedium)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<ReviewsCubit>(),
                child: VetReviewsScreen(
                  vetId:         p.vetId,
                  currentUserId: 0,
                ),
              ),
            )),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  RatingStarsWidget(rating: p.averageRating, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${p.averageRating.toStringAsFixed(1)} (${p.totalReviews} ${AppStrings.reviewTotalCount})',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMedium),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section: البروفايل (editable) ────────────────────────────────────────────

class _ProfileFormSection extends StatelessWidget {
  const _ProfileFormSection({
    required this.formKey,
    required this.bioCtrl,
    required this.expCtrl,
    required this.feeCtrl,
    required this.isLoading,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController bioCtrl, expCtrl, feeCtrl;
  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _Card(
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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

// ── Section: المناطق ─────────────────────────────────────────────────────────

class _RegionsSection extends StatelessWidget {
  const _RegionsSection({
    required this.loaded,
    required this.isLoading,
    required this.onAdd,
    required this.onRemove,
  });

  final VetProfileLoaded loaded;
  final bool isLoading;
  final VoidCallback onAdd;
  final void Function(RegionModel) onRemove;

  @override
  Widget build(BuildContext context) {
    final regions = loaded.profile.regions;
    return _Card(
      title: AppStrings.vetMyRegions,
      trailing: TextButton.icon(
        onPressed: isLoading ? null : onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text(AppStrings.addRegion),
      ),
      child: regions.isEmpty
          ? const Text('لم تضف أي منطقة بعد',
              style: TextStyle(color: AppColors.textMedium))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: regions
                  .map((r) => Chip(
                        label: Text(r.name),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: isLoading ? null : () => onRemove(r),
                        backgroundColor: AppColors.primarySurface,
                        labelStyle:
                            const TextStyle(color: AppColors.primary, fontSize: 13),
                      ))
                  .toList(),
            ),
    );
  }
}

// ── Section: مواعيد العمل ───────────────────────────────────────────────────

class _AvailabilitySection extends StatelessWidget {
  const _AvailabilitySection({
    required this.loaded,
    required this.isLoading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final VetProfileLoaded loaded;
  final bool isLoading;
  final VoidCallback onAdd;
  final void Function(AvailabilityModel) onEdit;
  final void Function(AvailabilityModel) onDelete;

  @override
  Widget build(BuildContext context) {
    final avails = loaded.availabilities;
    return _Card(
      title: AppStrings.vetMyAvailability,
      trailing: TextButton.icon(
        onPressed: isLoading ? null : onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text(AppStrings.addAvailability),
      ),
      child: avails.isEmpty
          ? const Text('لم تضف أي مواعيد بعد',
              style: TextStyle(color: AppColors.textMedium))
          : Column(
              children: avails.map((a) => _AvailabilityTile(
                    avail: a,
                    isLoading: isLoading,
                    onEdit: () => onEdit(a),
                    onDelete: () => onDelete(a),
                  )).toList(),
            ),
    );
  }
}

class _AvailabilityTile extends StatelessWidget {
  const _AvailabilityTile({
    required this.avail,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  final AvailabilityModel avail;
  final bool isLoading;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
        color: avail.isActive ? AppColors.primarySurface : Colors.grey.shade100,
      ),
      child: ListTile(
        leading: const Icon(Icons.schedule, color: AppColors.primary),
        title: Text(avail.dayNameAr,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${formatTimeDisplay(avail.startTime)} ← ${formatTimeDisplay(avail.endTime)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!avail.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('غير مفعّل',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
              onPressed: isLoading ? null : onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.error),
              onPressed: isLoading ? null : onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          child,
        ],
      ),
    );
  }
}

Widget _label(String text) => Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textMedium),
    );
