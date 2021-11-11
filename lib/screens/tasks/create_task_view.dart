import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';

class CreateTaskView extends StatefulWidget {
  final String errorMessage;

  const CreateTaskView({
    Key key,
    this.errorMessage,
  }) : super(key: key);

  @override
  _CreateTaskViewState createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _CreateTaskForm(context),
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

  Widget _CreateTaskForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _usernameField(context),
            _passwordField(context),
            _CreateTaskButton(context),
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

  Widget _CreateTaskButton(BuildContext context) {
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
              submitCreateTask(context);
            },
            child: Text('CreateTask'),
          ),
        ],
      ),
    );
  }

  void submitCreateTask(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      authCubit.performAuth(_username, _password);
    }
  }
}
