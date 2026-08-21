import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      if (isClosed) return;
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(AuthError(e.message));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError('حدث خطأ غير متوقع، حاول تاني.'));
    }
  }

  Future<void> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );
      if (isClosed) return;
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(AuthError(e.message));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError('حدث خطأ غير متوقع، حاول تاني.'));
    }
  }
}
