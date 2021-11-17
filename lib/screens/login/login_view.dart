import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';
import 'package:gorala/constants.dart';
import 'package:gorala/utils/email_validator.dart';

class LoginView extends StatefulWidget {
  final String errorMessage;
  final String userName;

  const LoginView({
    Key key,
    this.userName,
    this.errorMessage,
  }) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginForm(context),
    );
  }

  @override
  void initState() {
    super.initState();
    final authCubit = BlocProvider.of<AuthCubit>(context);

    if (authCubit.state is Foreign) {
      authCubit.checkIfAuthenticated();
    }
  }

  Widget _loginForm(BuildContext context) {
    return Container(
      width: kIsWeb ? 1000 : MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Spacer(),
              //_buildHeadline(context),
              Center(
                child: Column(children: [
                  _usernameField(context),
                  _passwordField(context),
                  _loginButton(context),
                ]),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                _registerButton(context),
                _forgotPasswordButton(context)
              ],),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kTitleTextColor),),
    );
  }

  Widget _usernameField(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }

        if (!EmailValidator.isEmail(value)) {
          return 'This does not look like a valid email';
        }

        _username = value;
        return null;
      },
      initialValue: widget.userName ?? '',
      keyboardType: TextInputType.emailAddress,
      autofillHints: [AutofillHints.email],
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        labelText: 'Email',
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        _password = value;
        return null;
      },
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: [AutofillHints.password],
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        labelText: 'Password',
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          widget.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SizedBox(),
          Container(
            width: 90,
            child: ElevatedButton(
              onPressed: () {
                _submitLogin(context);
              },
              child: Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/register');
        },
        child: Text(
          'Dont have an account?',
          style: TextStyle(decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Widget _forgotPasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/resetpassword');
        },
        child: Text(
          'Forgot password?',
          style: TextStyle(decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  void _submitLogin(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      authCubit.performAuth(_username, _password);
    }
  }
}
