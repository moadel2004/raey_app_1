import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../medical/cubit/medical_cubit.dart';
import '../../medical/screens/animal_medical_history_screen.dart';
import '../cubit/animals_cubit.dart';
import '../models/animal_model.dart';
import '../../farms/models/farm_model.dart';
import 'animal_form_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnimalsListScreen extends StatefulWidget {
  const AnimalsListScreen({super.key, required this.farm});
  final FarmModel farm;

  @override
  State<AnimalsListScreen> createState() => _AnimalsListScreenState();
}

class _AnimalsListScreenState extends State<AnimalsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnimalsCubit>().loadAnimals(widget.farm.id);
  }

  void _openForm({AnimalModel? animal}) {
    final cubit = context.read<AnimalsCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AnimalFormScreen(animal: animal, farmId: widget.farm.id),
        ),
      ),
    );
  }

  void _openHistory(AnimalModel animal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<MedicalCubit>(),
          child: AnimalMedicalHistoryScreen(
            animalId: animal.id,
            animalLabel: '${animal.type} — ${animal.officialTagId}',
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AnimalModel animal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(animal.type),
        content: const Text(AppStrings.animalDeleteConfirm),
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
    if (confirmed == true && mounted) {
      context.read<AnimalsCubit>().deleteAnimal(animal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('حيوانات ${widget.farm.name}'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<AnimalsCubit, AnimalsState>(
        listener: (context, state) {
          if (state is AnimalActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AnimalsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnimalsLoading || state is AnimalActionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is AnimalsError) {
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
                      onPressed: () => context.read<AnimalsCubit>().loadAnimals(
                        widget.farm.id,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('حاول تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AnimalsLoaded && state.animals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.animalsEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addAnimal),
                  ),
                ],
              ),
            );
          }

          if (state is AnimalsLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<AnimalsCubit>().loadAnimals(widget.farm.id),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: state.animals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _AnimalCard(
                  animal: state.animals[i],
                  onEdit: () => _openForm(animal: state.animals[i]),
                  onDelete: () => _confirmDelete(state.animals[i]),
                  onHistory: () => _openHistory(state.animals[i]),
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

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
  });

  final AnimalModel animal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.cow,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    animal.type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history_outlined,
                    size: 20,
                    color: Colors.teal,
                  ),
                  onPressed: onHistory,
                  tooltip: AppStrings.medicalAnimalHistory,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  onPressed: onEdit,
                  tooltip: AppStrings.editAnimal,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onPressed: onDelete,
                  tooltip: 'حذف',
                ),
              ],
            ),
            const Divider(height: 16, color: AppColors.border),
            _InfoRow(Icons.tag, AppStrings.animalTagId, animal.officialTagId),
            const SizedBox(height: 6),
            _InfoRow(
              Icons.category_outlined,
              AppStrings.animalBreed,
              animal.breed,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              animal.gender == 'Male'
                  ? Icons.male
                  : animal.gender == 'Female'
                  ? Icons.female
                  : Icons.help_outline,
              AppStrings.animalGender,
              animal.genderAr,
            ),
            if (animal.birthDate != null) ...[
              const SizedBox(height: 6),
              _InfoRow(
                Icons.cake_outlined,
                AppStrings.animalBirthDate,
                _formatDate(animal.birthDate!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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
            color: AppColors.textMedium,
          ),
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
