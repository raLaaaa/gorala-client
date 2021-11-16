import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';
import 'package:gorala/utils/email_validator.dart';

import '../../constants.dart';

class ForgotPasswordView extends StatefulWidget {
  final String errorMessage;
  final String userName;

  const ForgotPasswordView({
    Key key,
    this.userName,
    this.errorMessage,
  }) : super(key: key);

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _passwordRepeat = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ForgotPasswordForm(context),
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

  Widget _ForgotPasswordForm(BuildContext context) {
    return Center(
      child: Container(
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
                    _passwordRepeatField(context),
                    _ForgotPasswordButton(context),
                  ]),
                ),
                Spacer(),
                _alreadyHaveAnAccount(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('ForgotPassword', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kTitleTextColor)),
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

        if (_password != _passwordRepeat) {
          return 'Your passwords dont match';
        }

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

  Widget _passwordRepeatField(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        _passwordRepeat = value;

        if (_password != _passwordRepeat) {
          return 'Your passwords dont match';
        }
        return null;
      },
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: [AutofillHints.password],
      decoration: InputDecoration(
        icon: SizedBox(
          width: 24,
        ),
        labelText: 'Repeat password',
      ),
    );
  }

  Widget _ForgotPasswordButton(BuildContext context) {
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
          ElevatedButton(
            onPressed: () {
              _submitForgotPassword(context);
            },
            child: Text('Submit ForgotPassword'),
          ),
        ],
      ),
    );
  }

  Widget _alreadyHaveAnAccount(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/');
        },
        child: Text(
          'Remembered your password?',
          style: TextStyle(decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  void _submitForgotPassword(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      authCubit.register(_username, _password);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/success',
            (Route<dynamic> route) => false,
      );
    }
  }
}
