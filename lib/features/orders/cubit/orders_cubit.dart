import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/repository/auth_repository.dart';
import '../models/booking_model.dart';
import 'orders_state.dart';

export 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._apiClient, this._authRepository) : super(const OrdersInitial());

  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  bool get isVet => _authRepository.getCachedUser()?.isVeterinarian ?? false;

  Future<void> loadOrders() async {
    if (state is OrdersLoading) return;

    final user = _authRepository.getCachedUser();
    if (user == null) {
      emit(const OrdersError('مش قادر أحدد نوع الحساب، سجّل دخولك تاني.'));
      return;
    }

    final endpoint = user.isVeterinarian
        ? ApiEndpoints.vetBookings
        : ApiEndpoints.myBookings;

    emit(const OrdersLoading());
    try {
      final response = await _apiClient.dio.get(endpoint);
      final body = response.data;

      final dataField = body is Map ? body['data'] : null;
      final List<dynamic> raw =
          (dataField is Map && dataField['items'] is List)
              ? dataField['items'] as List
              : [];

      final orders = raw
          .whereType<Map<String, dynamic>>()
          .map(BookingModel.fromJson)
          .toList();

      if (isClosed) return;
      emit(OrdersLoaded(orders));
    } on DioException catch (e) {
      debugPrint('[OrdersCubit] DioException ${e.response?.statusCode}: ${e.message}');
      if (isClosed) return;
      emit(OrdersError(mapDioError(e)));
    } on ApiException catch (e) {
      debugPrint('[OrdersCubit] ApiException: ${e.message}');
      if (isClosed) return;
      emit(OrdersError(e.message));
    } catch (e, st) {
      debugPrint('[OrdersCubit] unexpected: $e\n$st');
      if (isClosed) return;
      emit(OrdersError('تعذّر تحميل الطلبات، حاول تاني.'));
    }
  }

  Future<void> updateBookingStatus(int id, String newStatus) async {
    try {
      await _apiClient.dio.put(
        ApiEndpoints.bookingStatus(id),
        data: {'newStatus': newStatus},
      );
      if (isClosed) return;
      await loadOrders();
    } on DioException catch (e) {
      debugPrint('[OrdersCubit] updateStatus error: ${e.message}');
      if (isClosed) return;
      emit(OrdersError(mapDioError(e)));
    } catch (e) {
      if (isClosed) return;
      emit(const OrdersError('تعذّر تحديث الحجز، حاول تاني.'));
    }
  }

  Future<void> cancelBooking(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.bookingById(id));
      if (isClosed) return;
      await loadOrders();
    } on DioException catch (e) {
      debugPrint('[OrdersCubit] cancelBooking error: ${e.message}');
      if (isClosed) return;
      emit(OrdersError(mapDioError(e)));
    } catch (e) {
      if (isClosed) return;
      emit(const OrdersError('تعذّر إلغاء الحجز، حاول تاني.'));
    }
  }
}
