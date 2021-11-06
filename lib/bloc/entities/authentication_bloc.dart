import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';
import 'form_submission_status.dart';


class AuthenticationBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationRepository authRepo;

  AuthenticationBloc({this.authRepo}) : super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // Username updated
    if (event is LoginUsernameChanged) {
      yield state.copyWith(username: event.username);

      // Password updated
    } else if (event is LoginPasswordChanged) {
      yield state.copyWith(password: event.password);

      // Form submitted
    } else if (event is LoginSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        await authRepo.login();
        yield state.copyWith(formStatus: SubmissionSuccess());
      } catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    }
  }
}