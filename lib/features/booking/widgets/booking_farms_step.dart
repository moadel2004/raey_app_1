import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/booking_cubit.dart';
import 'booking_empty_view.dart';
import 'booking_select_card.dart';

class BookingFarmsStep extends StatelessWidget {
  const BookingFarmsStep({super.key, required this.state});

  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.farms.isEmpty) {
      return BookingEmptyView(
        icon: Icons.agriculture_outlined,
        message: AppStrings.bookNoFarms,
        onRetry: () => context.read<BookingCubit>().loadFarms(),
        showRetry: state.error != null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: state.farms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final farm = state.farms[i];
        return BookingSelectCard(
          onTap: () => context.read<BookingCubit>().selectFarm(farm),
          icon: Icons.agriculture_outlined,
          title: farm.name,
          subtitle: '${farm.location} — ${farm.regionName}',
          trailing: '${farm.animalCount} حيوانات',
        );
      },
    );
  }
}
