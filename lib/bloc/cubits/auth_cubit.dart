import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';
import 'package:gorala/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  static bool _checkedInitialAuth = false;

  AuthCubit(this._authRepository) : super(Foreign());

  Future<void> checkIfAuthenticated() async {

    if(!_checkedInitialAuth) {
      _checkedInitialAuth = true;
      emit(AuthLoading());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('AUTH_TOKEN') ?? '';
      var id = prefs.getString('ID') ?? '';
      var mail = prefs.getString('EMAIL') ?? '';

      if (token.isNotEmpty) {
        AuthRepository.AUTH_TOKEN = token;
        final loggedIn = await _authRepository.checkLogin();

        if (loggedIn) {
          emit(Authenticated(new User(id, mail, token)));
          return;
        }
        else {
          emit(Foreign());
          return;
        }
      } else {
        emit(Foreign());
      }
    }
    else{
      emit(Foreign());
    }

  }

  Future<void> performAuth(String username, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authRepository.login(username, password);

      if(user == null){
        emit(AuthError("Invalid Credentials", username));
        return;
      }

      emit(Authenticated(user));
    } on Exception catch(e){

      if(e is TimeoutException){
        emit(AuthError("Server not reachable", username));
        return;
      }

      emit(AuthError(e.toString(), username));
    }
  }

  Future<void> register(String username, String password) async {
    try {
      emit(AuthLoading());
      bool success = await _authRepository.register(username, password);

      if(!success){
        emit(RegistrationError("Registration Error"));
        return;
      }

      emit(Foreign());
    } on Exception catch(e){

      if(e is TimeoutException){
        emit(AuthError("Server not reachable", username));
        return;
      }

      emit(AuthError(e.toString(), username));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(Foreign());
  }
}