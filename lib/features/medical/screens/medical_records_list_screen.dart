import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/medical_cubit.dart';
import '../models/medical_record_model.dart';
import 'medical_record_details_screen.dart';

class MedicalRecordsListScreen extends StatefulWidget {
  const MedicalRecordsListScreen({super.key, required this.vetId});

  final int vetId;

  @override
  State<MedicalRecordsListScreen> createState() =>
      _MedicalRecordsListScreenState();
}

class _MedicalRecordsListScreenState
    extends State<MedicalRecordsListScreen> {
  String? _filterVisitType;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<MedicalCubit>().loadRecords(
          veterinarianId: widget.vetId,
          visitType: _filterVisitType,
        );
  }

  void _openDetails(MedicalRecordModel record) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<MedicalCubit>(),
            child: MedicalRecordDetailsScreen(
              record: record,
              isVet:  true,
              vetId:  widget.vetId,
            ),
          ),
        ))
        .then((refreshed) {
      if (refreshed == true) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.medicalRecordsTitle),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: AppStrings.visitTypeLabel,
            onSelected: (v) {
              setState(() => _filterVisitType = v);
              _load();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: null,
                child: Text('الكل', style: TextStyle(fontFamily: 'Cairo')),
              ),
              const PopupMenuItem(
                value: 'Examination',
                child: Text(AppStrings.visitTypeExamination,
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
              const PopupMenuItem(
                value: 'FollowUp',
                child: Text(AppStrings.visitTypeFollowUp,
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
              const PopupMenuItem(
                value: 'Emergency',
                child: Text(AppStrings.visitTypeEmergency,
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
              const PopupMenuItem(
                value: 'Vaccination',
                child: Text(AppStrings.visitTypeVaccination,
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<MedicalCubit, MedicalState>(
        builder: (context, state) {
          if (state is MedicalLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is MedicalError) {
            return _ErrorView(
              message: state.message,
              onRetry: _load,
            );
          }

          if (state is MedicalRecordsLoaded) {
            if (state.records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open_outlined,
                        size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.medicalEmpty,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    if (_filterVisitType != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() => _filterVisitType = null);
                          _load();
                        },
                        child: const Text(
                          'إزالة الفلتر',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _load(),
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.records.length,
                separatorBuilder: (_, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final r = state.records[i];
                  return _RecordCard(
                    record: r,
                    onTap: () => _openDetails(r),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onTap});

  final MedicalRecordModel record;
  final VoidCallback onTap;

  String get _visitTypeAr {
    switch (record.visitType) {
      case 'Examination': return AppStrings.visitTypeExamination;
      case 'FollowUp':    return AppStrings.visitTypeFollowUp;
      case 'Emergency':   return AppStrings.visitTypeEmergency;
      case 'Vaccination': return AppStrings.visitTypeVaccination;
      default:            return record.visitType;
    }
  }

  Color get _visitColor {
    switch (record.visitType) {
      case 'Emergency':   return Colors.red;
      case 'Examination': return Colors.blue;
      case 'FollowUp':    return Colors.orange;
      case 'Vaccination': return Colors.green;
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Visit type chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _visitColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _visitTypeAr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _visitColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Main info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.animalType} — ${record.animalTagId}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (record.diagnosis != null)
                      Text(
                        record.diagnosis!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(record.createdAt),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'حاول تاني',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
