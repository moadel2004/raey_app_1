import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/farms_cubit.dart';
import '../models/farm_model.dart';
import '../../animals/cubit/animals_cubit.dart';
import '../../animals/screens/animals_list_screen.dart';
import 'farm_form_screen.dart';

class FarmsListScreen extends StatefulWidget {
  const FarmsListScreen({super.key});

  @override
  State<FarmsListScreen> createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends State<FarmsListScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<FarmsCubit>();
    cubit.loadRegions().then((_) {
      if (!cubit.isClosed) cubit.loadFarms();
    });
  }

  Future<void> _openAnimals(FarmModel farm) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<AnimalsCubit>(),
          child: AnimalsListScreen(farm: farm),
        ),
      ),
    );
    if (mounted) context.read<FarmsCubit>().loadFarms();
  }

  void _openForm({FarmModel? farm}) {
    final cubit = context.read<FarmsCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: FarmFormScreen(farm: farm),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, FarmModel farm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(farm.name),
        content: const Text(AppStrings.farmDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<FarmsCubit>().deleteFarm(farm.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.farmsTitle),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<FarmsCubit, FarmsState>(
        listener: (context, state) {
          if (state is FarmActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is FarmsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FarmsLoading || state is FarmActionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is FarmsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<FarmsCubit>().loadFarms(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('حاول تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is FarmsLoaded && state.farms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.farmsEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addFarm),
                  ),
                ],
              ),
            );
          }

          if (state is FarmsLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<FarmsCubit>().loadFarms(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: state.farms.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _FarmCard(
                  farm: state.farms[i],
                  onTap: () => _openAnimals(state.farms[i]),
                  onEdit: () => _openForm(farm: state.farms[i]),
                  onDelete: () => _confirmDelete(context, state.farms[i]),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  const _FarmCard({
    required this.farm,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final FarmModel farm;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.agriculture, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    farm.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.primary),
                  onPressed: onEdit,
                  tooltip: AppStrings.editFarm,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'حذف',
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.primary),
              ],
            ),
            const Divider(height: 16, color: AppColors.border),
            _InfoRow(Icons.location_on_outlined, AppStrings.farmLocation, farm.location),
            const SizedBox(height: 6),
            _InfoRow(Icons.map_outlined, AppStrings.farmRegion, farm.regionName),
            const SizedBox(height: 6),
            _InfoRow(Icons.pets_outlined, AppStrings.farmAnimalCount,
                '${farm.animalCount} حيوان'),
          ],
        ),
      ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}
