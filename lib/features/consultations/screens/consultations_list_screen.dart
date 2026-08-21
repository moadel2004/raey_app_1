import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/repository/auth_repository.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/consultations_cubit.dart';
import '../models/consultation_model.dart';
import 'chat_screen.dart';
import 'consultation_form_screen.dart';

class ConsultationsListScreen extends StatefulWidget {
  const ConsultationsListScreen({super.key});

  @override
  State<ConsultationsListScreen> createState() => _ConsultationsListScreenState();
}

class _ConsultationsListScreenState extends State<ConsultationsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConsultationsCubit>().loadConsultations();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted': return AppColors.success;
      case 'Pending':  return AppColors.warning;
      case 'Rejected': return AppColors.error;
      case 'Closed':   return AppColors.textLight;
      default:         return AppColors.textLight;
    }
  }

  Future<void> _confirmAction({
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (ok == true && mounted) onConfirm();
  }

  void _openChat(ConsultationModel c, bool isVet) {
    final currentUserId =
        sl<AuthRepository>().getCachedUser()?.id ?? 0;
    final otherParty = isVet ? c.farmerName : c.vetName;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ChatCubit>(),
          child: ChatScreen(
            consultationId: c.consultationId,
            currentUserId:  currentUserId,
            otherPartyName: otherParty,
            subject:        c.subject,
          ),
        ),
      ),
    );
  }

  Future<void> _openForm() async {
    final cubit = context.read<ConsultationsCubit>();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const ConsultationFormScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConsultationsCubit, ConsultationsState>(
      listener: (context, state) {
        if (state is ConsultationActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
          ));
        }
        if (state is ConsultationsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ));
        }
      },
      builder: (context, state) {
        final cubit  = context.read<ConsultationsCubit>();
        final isVet  = cubit.isVet;
        final title  = isVet
            ? AppStrings.vetConsultationsTitle
            : AppStrings.consultationsTitle;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(title)),
          floatingActionButton: isVet
              ? null
              : FloatingActionButton.extended(
                  onPressed: _openForm,
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(AppStrings.consultationOnline,
                      style: TextStyle(color: Colors.white)),
                ),
          body: _buildBody(context, state, cubit, isVet),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ConsultationsState state,
    ConsultationsCubit cubit,
    bool isVet,
  ) {
    // Loading
    if (state is ConsultationsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Error (full-screen)
    if (state is ConsultationsError) {
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
                onPressed: cubit.loadConsultations,
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
              ),
            ],
          ),
        ),
      );
    }

    final consultations = state is ConsultationsLoaded ? state.consultations : [];
    final isAction      = state is ConsultationActionLoading;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: cubit.loadConsultations,
      child: consultations.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: consultations.length,
              itemBuilder: (_, i) => _ConsultationCard(
                consultation: consultations[i],
                isVet: isVet,
                isActionLoading: isAction,
                statusColor: _statusColor,
                onAccept: () => _confirmAction(
                  title: 'قبول الاستشارة',
                  content: 'هتقبل الاستشارة دي؟',
                  confirmLabel: AppStrings.consultActionAccept,
                  confirmColor: AppColors.success,
                  onConfirm: () => cubit.acceptConsultation(consultations[i].consultationId),
                ),
                onReject: () => _confirmAction(
                  title: 'رفض الاستشارة',
                  content: 'هترفض الاستشارة دي؟',
                  confirmLabel: AppStrings.consultActionReject,
                  confirmColor: AppColors.error,
                  onConfirm: () => cubit.rejectConsultation(consultations[i].consultationId),
                ),
                onClose: () => _confirmAction(
                  title: 'إقفال الاستشارة',
                  content: 'هتقفل الاستشارة دي؟',
                  confirmLabel: AppStrings.consultActionClose,
                  confirmColor: AppColors.textMedium,
                  onConfirm: () => cubit.closeConsultation(consultations[i].consultationId),
                ),
                onOpenChat: () => _openChat(consultations[i], isVet),
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Column(
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              AppStrings.consultationEmpty,
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
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({
    required this.consultation,
    required this.isVet,
    required this.isActionLoading,
    required this.statusColor,
    required this.onAccept,
    required this.onReject,
    required this.onClose,
    required this.onOpenChat,
  });

  final ConsultationModel consultation;
  final bool isVet;
  final bool isActionLoading;
  final Color Function(String) statusColor;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onClose;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final c     = consultation;
    final color = statusColor(c.status);
    final d     = c.createdAt;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    // Vet sees farmer name; farmer sees vet name
    final otherParty = isVet ? c.farmerName : c.vetName;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(c.subject,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textDark,
                          fontFamily: 'Cairo')),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(c.statusAr,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                          fontFamily: 'Cairo')),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Other party + date
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(otherParty,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMedium)),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMedium)),
              ],
            ),
            // Vet action buttons
            if (isVet && (c.isPending || c.isAccepted)) ...[
              const Divider(height: 20, color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (c.isPending) ...[
                    _ActionBtn(
                      label: AppStrings.consultActionAccept,
                      color: AppColors.success,
                      onPressed: isActionLoading ? null : onAccept,
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      label: AppStrings.consultActionReject,
                      color: AppColors.error,
                      onPressed: isActionLoading ? null : onReject,
                    ),
                  ],
                  if (c.isAccepted) ...[
                    _ActionBtn(
                      label: AppStrings.consultActionClose,
                      color: AppColors.textMedium,
                      onPressed: isActionLoading ? null : onClose,
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      label: AppStrings.consultOpenChat,
                      color: AppColors.primary,
                      onPressed: onOpenChat,
                    ),
                  ],
                ],
              ),
            ],
            // Chat button for farmer (when Accepted)
            if (!isVet && c.isAccepted) ...[
              const Divider(height: 20, color: AppColors.border),
              Align(
                alignment: Alignment.centerLeft,
                child: _ActionBtn(
                  label: AppStrings.consultOpenChat,
                  color: AppColors.primary,
                  onPressed: onOpenChat,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontFamily: 'Cairo')),
    );
  }
}
