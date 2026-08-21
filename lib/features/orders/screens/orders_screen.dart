import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../medical/cubit/medical_cubit.dart';
import '../../medical/screens/medical_record_form_screen.dart';
import '../../reviews/cubit/reviews_cubit.dart';
import '../../reviews/screens/review_form_screen.dart';
import '../../vet_profile/cubit/vet_profile_cubit.dart';
import '../cubit/orders_cubit.dart';
import '../models/booking_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<OrdersCubit>();
    // حمّل بس لو مش شغّال أو ما حمّلش قبل كده
    if (cubit.state is OrdersInitial) {
      cubit.loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.read<OrdersCubit>().isVet
              ? AppStrings.ordersScreenVet
              : AppStrings.ordersScreenFarmer,
        ),
      ),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listenWhen: (p, c) => c is OrdersError && c != p,
        listener: (context, state) {
          if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is OrdersError) {
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
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<OrdersCubit>().loadOrders(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('حاول تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is OrdersLoaded && state.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'مفيش طلبات لسه',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (state is OrdersLoaded) {
            final isVet = context.read<OrdersCubit>().isVet;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<OrdersCubit>().loadOrders(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _BookingCard(
                  booking: state.orders[i],
                  isVet: isVet,
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.isVet});
  final BookingModel booking;
  final bool isVet;

  Color _statusColor() {
    if (booking.isConfirmed) return AppColors.success;
    if (booking.isPending)   return AppColors.warning;
    if (booking.isCancelled) return AppColors.error;
    return AppColors.textLight;
  }

  @override
  Widget build(BuildContext context) {
    final scheduled = booking.scheduledAt;
    final dateStr =
        '${scheduled.year}/${scheduled.month.toString().padLeft(2, '0')}/${scheduled.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}';

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
            // رأس الكارت: نوع الحجز + حالته
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.agriculture_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      booking.typeAr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor().withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(), width: 1),
                  ),
                  child: Text(
                    booking.statusAr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),

            // الدكتور
            _InfoRow(
              icon: Icons.medical_services_outlined,
              label: 'الدكتور',
              value: booking.veterinarian.fullName,
            ),

            // المزرعة
            if (booking.farm != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.home_work_outlined,
                label: 'المزرعة',
                value: '${booking.farm!.name} — ${booking.farm!.location}',
              ),
            ],

            // التاريخ والوقت
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'الموعد',
              value: '$dateStr  $timeStr',
            ),

            // الحيوانات
            if (booking.animals.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.pets_outlined,
                label: 'الحيوانات',
                value: booking.animals
                    .map((a) => '${a.type} (${a.breed})')
                    .join('، '),
              ),
            ],

            // Action buttons
            if (_showActions) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              _actionRow(context),
            ],
          ],
        ),
      ),
    );
  }

  bool get _showActions {
    if (isVet) return booking.isPending || booking.isConfirmed || booking.isCompleted;
    return booking.isPending || booking.isConfirmed || booking.isCompleted;
  }

  Widget _actionRow(BuildContext context) {
    final cubit = context.read<OrdersCubit>();
    if (isVet) {
      if (booking.isPending) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => cubit.updateBookingStatus(booking.bookingId, 'Confirmed'),
                child: const Text(AppStrings.actionAccept),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => cubit.updateBookingStatus(booking.bookingId, 'Cancelled'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text(AppStrings.actionReject),
              ),
            ),
          ],
        );
      }
      if (booking.isConfirmed) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => cubit.updateBookingStatus(booking.bookingId, 'Completed'),
            child: const Text(AppStrings.actionComplete),
          ),
        );
      }
      if (booking.isCompleted) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit_note, size: 18),
            label: const Text(
              AppStrings.medicalWriteReport,
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onPressed: () {
              final vetProfileCubit = context.read<VetProfileCubit>();
              final vetId = vetProfileCubit.cached?.profile.vetId;
              if (vetId == null || vetId == 0) {
                vetProfileCubit.loadAll();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'جاري تحميل بيانات البروفايل، حاول تاني',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  duration: Duration(seconds: 3),
                ));
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<MedicalCubit>(),
                  child: MedicalRecordFormScreen(
                    vetId:     vetId,
                    bookingId: booking.bookingId,
                    animals:   booking.animals,
                  ),
                ),
              ));
            },
          ),
        );
      }
    } else {
      // Farmer: cancel pending or confirmed
      if (booking.isPending || booking.isConfirmed) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('إلغاء الطلب'),
                  content: const Text(AppStrings.confirmCancelOrder),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('لأ'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                context.read<OrdersCubit>().cancelBooking(booking.bookingId);
              }
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.actionCancel),
          ),
        );
      }
      // Farmer: rate the vet after a completed visit
      if (booking.isCompleted) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.star_outline, size: 18),
            label: const Text(
              AppStrings.reviewVet,
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<ReviewsCubit>(),
                  child: ReviewFormScreen(
                    vetId:     booking.veterinarian.vetId,
                    bookingId: booking.bookingId,
                  ),
                ),
              ));
            },
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
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
