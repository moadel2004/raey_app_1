import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/vet_profile_cubit.dart';
import '../models/availability_model.dart';
import '../widgets/availability_form_sheet.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  @override
  void initState() {
    super.initState();
    // Reload so the screen always shows fresh data.
    context.read<VetProfileCubit>().loadAll();
  }

  Future<void> _refresh() => context.read<VetProfileCubit>().loadAll();

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<VetProfileCubit>(),
        child: const AvailabilityFormSheet(),
      ),
    );
  }

  void _openEditSheet(AvailabilityModel a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<VetProfileCubit>(),
        child: AvailabilityFormSheet(availability: a),
      ),
    );
  }

  Future<void> _confirmDelete(AvailabilityModel a) async {
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
      appBar: AppBar(title: const Text(AppStrings.vetMyAvailability)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(AppStrings.addAvailability,
            style: TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<VetProfileCubit, VetProfileState>(
        listener: (context, state) {
          if (state is VetActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ));
          }
          if (state is VetProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          final cubit      = context.read<VetProfileCubit>();
          final loaded     = state is VetProfileLoaded ? state : cubit.cached;
          final isAction   = state is VetActionLoading;

          // ── Full-screen loading ─────────────────────────────────────────
          if (state is VetProfileLoading && loaded == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // ── Full-screen error ───────────────────────────────────────────
          if (state is VetProfileError && loaded == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_outlined,
                        size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 15)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('حاول تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          final avails = (loaded?.availabilities ?? [])
            ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: avails.isEmpty
                ? _buildEmpty()
                : _buildList(avails, isAction),
          );
        },
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Column(
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              AppStrings.availabilityEmpty,
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 15,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── List ────────────────────────────────────────────────────────────────

  Widget _buildList(List<AvailabilityModel> avails, bool isAction) {
    // Group by dayOfWeek
    final Map<int, List<AvailabilityModel>> grouped = {};
    for (final a in avails) {
      grouped.putIfAbsent(a.dayOfWeek, () => []).add(a);
    }
    final days = grouped.keys.toList()..sort();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final day   = days[i];
        final items = grouped[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(
                kDayNamesAr[day],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            ...items.map((a) => _AvailabilityTile(
                  availability: a,
                  isLoading: isAction,
                  onEdit: () => _openEditSheet(a),
                  onDelete: () => _confirmDelete(a),
                )),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _AvailabilityTile extends StatelessWidget {
  const _AvailabilityTile({
    required this.availability,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  final AvailabilityModel availability;
  final bool isLoading;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final a = availability;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: a.isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      color: a.isActive ? AppColors.primarySurface : Colors.grey.shade50,
      child: ListTile(
        leading: Icon(
          Icons.access_time,
          color: a.isActive ? AppColors.primary : AppColors.textLight,
        ),
        title: Row(
          children: [
            Text(
              '${formatTimeDisplay(a.startTime)}  →  ${formatTimeDisplay(a.endTime)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: 'Cairo',
              ),
            ),
            if (!a.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('غير مفعّل',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 20, color: AppColors.primary),
              onPressed: isLoading ? null : onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.error),
              onPressed: isLoading ? null : onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
