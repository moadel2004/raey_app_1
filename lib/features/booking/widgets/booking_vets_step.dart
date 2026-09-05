import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../reviews/cubit/reviews_cubit.dart';
import '../../reviews/screens/vet_reviews_screen.dart';
import '../cubit/booking_cubit.dart';
import 'booking_empty_view.dart';
import 'booking_vet_card.dart';

class BookingVetsStep extends StatelessWidget {
  const BookingVetsStep({super.key, required this.state});

  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.vets.isEmpty) {
      return BookingEmptyView(
        icon: Icons.medical_services_outlined,
        message: AppStrings.bookNoVets,
        onRetry: () => context.read<BookingCubit>().retryLoadVets(),
        showRetry: state.error != null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: state.vets.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final vet = state.vets[i];
        return BookingVetCard(
          vet: vet,
          onSelect: () => context.read<BookingCubit>().selectVet(vet),
          onViewReviews: vet.totalReviews > 0
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<ReviewsCubit>(),
                      child: VetReviewsScreen(
                        vetId: vet.vetId,
                        currentUserId: 0,
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
