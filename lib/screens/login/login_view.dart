import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/entities/authentication_bloc.dart';
import 'package:gorala/bloc/entities/authentication_event.dart';
import 'package:gorala/bloc/entities/authentication_state.dart';
import 'package:gorala/bloc/entities/form_submission_status.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';

class LoginView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AuthenticationBloc(
          authRepo: context.read<AuthenticationRepository>(),
        ),
        child: _loginForm(),
      ),
    );
  }

  Widget _loginForm() {
    return BlocListener<AuthenticationBloc, LoginState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            _showSnackBar(context, formStatus.exception.toString());
          }
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _usernameField(),
                _passwordField(),
                _loginButton(),
              ],
            ),
          ),
        ));
  }

  Widget _usernameField() {
    return BlocBuilder<AuthenticationBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Username',
        ),
        validator: (value) =>
        state.isValidUsername ? null : 'Username is too short',
        onChanged: (value) => context.read<AuthenticationBloc>().add(
          LoginUsernameChanged(username: value),
        ),
      );
    });
  }

  Widget _passwordField() {
    return BlocBuilder<AuthenticationBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: 'Password',
        ),
        validator: (value) =>
        state.isValidPassword ? null : 'Password is too short',
        onChanged: (value) => context.read<AuthenticationBloc>().add(
          LoginPasswordChanged(password: value),
        ),
      );
    });
  }

  Widget _loginButton() {
    return BlocBuilder<AuthenticationBloc, LoginState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            context.read<AuthenticationBloc>().add(LoginSubmitted());
          }
        },
        child: Text('Login'),
      );
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}