import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';
import 'package:gorala/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(Foreign());

  Future<void> checkIfAuthenticated() async {
    emit(AuthLoading());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('AUTH_TOKEN') ?? '';
    var id = prefs.getString('ID') ?? '';
    var mail = prefs.getString('EMAIL') ?? '';

    if(token.isNotEmpty){
      AuthRepository.AUTH_TOKEN = token;
      final loggedIn = await _authRepository.checkLogin();

      if(loggedIn){
        emit(Authenticated(new User(id, mail, token)));
        return;
      }
      else{
        emit(Foreign());
        return;
      }


    } else {
      emit(Foreign());
    }

  }

  Future<void> performAuth(String username, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authRepository.login(username, password);

      if(user == null){
        emit(AuthError("Invalid Credentials"));
        return;
      }

      emit(Authenticated(user));
    } on Exception catch(e){
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(Foreign());
  }
}