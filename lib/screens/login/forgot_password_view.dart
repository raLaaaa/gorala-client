import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gorala/services/api/api_client.dart';
import 'package:gorala/utils/email_validator.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({
    Key key,
  }) : super(key: key);

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ForgotPasswordForm(context),
    );
  }

  @override
  void initState() {
    super.initState();
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
                    _ForgotPasswordButton(context),
                  ]),
                ),
                Spacer(),
                _rememberedYourPassword(context)
              ],
            ),
          ),
        ),
      ),
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
      keyboardType: TextInputType.emailAddress,
      autofillHints: [AutofillHints.email],
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        labelText: 'Email',
      ),
    );
  }

  Widget _ForgotPasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SizedBox(),
          ElevatedButton(
            onPressed: () {
              _submitForgotPassword(context);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _rememberedYourPassword(BuildContext context) {
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

  void _submitForgotPassword(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      var baseUrl = kIsWeb ? dotenv.env['SERVER_LOCAL'] : dotenv.env['SERVER'];
      var uri = baseUrl + '/reset/request';
      var data = {'username': _username};

      try {
        var response = await http.post(uri, body: jsonEncode(data), headers: {'Content-Type': 'application/json'}).timeout(ApiClient.timeOutDuration);

        if (response.statusCode != 200) {
          setState(() {
            _errorMessage = 'We did not find a user with this mail';
          });
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/successreset',
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }
}
