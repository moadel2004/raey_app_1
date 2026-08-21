import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_state.dart';

export 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (isClosed) return;
      emit(const NotificationsLoaded([]));
    } catch (e) {
      if (isClosed) return;
      emit(NotificationsError(e.toString()));
    }
  }
}
