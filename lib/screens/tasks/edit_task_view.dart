import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';

class EditTaskView extends StatefulWidget {
  final String errorMessage;

  const EditTaskView({
    Key key,
    this.errorMessage,
  }) : super(key: key);

  @override
  _EditTaskViewState createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _EditTaskForm(context),
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

  Widget _EditTaskForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _usernameField(context),
            _passwordField(context),
            _EditTaskButton(context),
          ],
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
        _username = value;
        return null;
      },
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        hintText: 'Username',
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
      decoration: InputDecoration(
        icon: Icon(Icons.security),
        hintText: 'Password',
      ),
    );
  }

  Widget _EditTaskButton(BuildContext context) {
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
              submitEditTask(context);
            },
            child: Text('EditTask'),
          ),
        ],
      ),
    );
  }

  void submitEditTask(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      authCubit.performAuth(_username, _password);
    }
  }
}
