import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/booking_cubit.dart';
import '../widgets/booking_animals_step.dart';
import '../widgets/booking_confirm_step.dart';
import '../widgets/booking_farms_step.dart';
import '../widgets/booking_step_dots.dart';
import '../widgets/booking_success_view.dart';
import '../widgets/booking_type_date_step.dart';
import '../widgets/booking_vets_step.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key, this.initialType = 'FarmVisit'});
  final String initialType;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<BookingCubit>();
    cubit.setInitialType(widget.initialType);
    cubit.loadFarms();
  }

  void _handleBack() {
    final cubit = context.read<BookingCubit>();
    if (cubit.state.step > 0 && !cubit.state.isSuccess) {
      cubit.prevStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  String _appBarTitle(int step, bool isSuccess) {
    if (isSuccess) return AppStrings.bookConfirm;
    return const [
      AppStrings.bookSelectFarm,
      AppStrings.bookSelectVet,
      AppStrings.bookSelectAnimals,
      AppStrings.bookTypeAndDate,
      AppStrings.bookConfirm,
    ][step.clamp(0, 4)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingFlowState>(
      listenWhen: (p, c) => c.error != null && c.error != p.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _handleBack();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _handleBack,
              ),
              title: Text(_appBarTitle(state.step, state.isSuccess)),
            ),
            body: state.isSuccess
                ? BookingSuccessView(
                    onDone: () => Navigator.of(context).pop(true),
                  )
                : Column(
                    children: [
                      BookingStepDots(currentStep: state.step),
                      Expanded(child: _stepContent(state)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _stepContent(BookingFlowState state) {
    switch (state.step) {
      case 0:
        return BookingFarmsStep(state: state);
      case 1:
        return BookingVetsStep(state: state);
      case 2:
        return BookingAnimalsStep(state: state);
      case 3:
        return const BookingTypeDateStep();
      case 4:
        return BookingConfirmStep(state: state);
      default:
        return const SizedBox.shrink();
    }
  }
}
