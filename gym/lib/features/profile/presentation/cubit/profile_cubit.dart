import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/profile.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState.initial());

  Future<void> loadProfile() async {
    emit(const ProfileState.loading());
    
    // TODO: Load from repository (SharedPreferences/API)
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock profile
    const mockProfile = Profile(
      id: 'mock_user_1',
      phoneNumber: '+1234567890',
      firstName: 'John',
      lastName: 'Doe',
    );
    
    emit(const ProfileState.loaded(mockProfile));
  }
}
