import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';
import 'package:gorala/models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _AuthRepository;

  AuthCubit(this._AuthRepository) : super(Foreign());

  Future<void> performAuth(String username, String password) async {
    try {
      emit(AuthLoading());
      final user = await _AuthRepository.login(username, password);

      if(user == null){
        emit(AuthError("Invalid Credentials"));
        return;
      }

      emit(Authenticated(user));
    } on Exception catch(e){
      emit(AuthError(e.toString()));
    }
  }
}