import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/repository/auth_repository.dart';
import 'profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._authRepository) : super(const ProfileInitial());

  final AuthRepository _authRepository;

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final user = _authRepository.getCachedUser();
    if (user == null) {
      emit(const ProfileError('مفيش بيانات مستخدم، سجّل دخولك تاني.'));
      return;
    }
    emit(ProfileLoaded(user));
  }

  Future<void> signOut() => _authRepository.logout();
}
