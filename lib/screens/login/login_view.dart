import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';

class LoginView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final String _errorMessage;
  String _username = '';
  String _password = '';

  LoginView([this._errorMessage]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginForm(context),
    );
  }

  Widget _loginForm(BuildContext context)  {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _usernameField(context),
            _passwordField(context),
            _loginButton(context),
          ],
        ),
      ),
    );
  }

  Widget _usernameField(BuildContext context)  {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        _username = value;
        return null;
      },
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        hintText: 'Username',
      ),
    );
  }

  Widget _passwordField(BuildContext context)  {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        _password = value;
        return null;
      },
      obscureText: true,
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        hintText: 'Password',
      ),
    );
  }

  Widget _loginButton(BuildContext context)  {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _errorMessage != null ? Text(_errorMessage, style: TextStyle(color: Colors.red),) : SizedBox(),
          ElevatedButton(
            onPressed:() {submitLogin(context);},
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  void submitLogin(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      authCubit.performAuth(_username, _password);
    }
  }
}
