import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/constants.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/screens/main/main_screen.dart';
import 'package:intl/intl.dart';

class EditTaskArguments {
  final Task task;

  EditTaskArguments(this.task);
}

class EditTaskView extends StatefulWidget {
  final Task task;

  const EditTaskView({
    Key key,
    this.task,
  }) : super(key: key);

  @override
  _EditTaskViewState createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  final _formKey = GlobalKey<FormState>();
  DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  DateTime _initialDate = DateTime.now();
  DateTime _selectedDate;
  String _taskDescription;
  String _errorMessage;
  Task _taskToEdit;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as EditTaskArguments;

    if(args != null) {
      _taskToEdit = args.task;
      _initialDate = _taskToEdit.executionDate;
      _taskDescription = _taskToEdit.description;
    }
    else{
      return Text('404 - Invalid Data');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit your task', style: TextStyle(fontSize: 28)),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: Icon(Icons.delete),
            onPressed: () {
              final taskCubit = BlocProvider.of<TaskCubit>(context);
              taskCubit.deleteTask(_taskToEdit);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (Route<dynamic> route) => false,
                arguments: MainScreenArguments(_taskToEdit.executionDate),
              );
            },
          ),
        ],
      ),
      body: _EditTaskForm(context),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _EditTaskForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: kIsWeb ? 700 : MediaQuery.of(context).size.width,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _selectTaskDate(context),
                  Divider(),
                  _buildTaskDescription(context),
                  _editTaskButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectTaskDate(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Task date:', style: TextStyle(fontSize: 16)),
        InkWell(
            onTap: () {
              _selectDate(context);
            },
            child: Row(children: [
              _selectedDate != null
                  ? Text(
                      _dateFormat.format(_selectedDate),
                      style: TextStyle(fontSize: 16),
                    )
                  : Text(
                      _dateFormat.format(_initialDate),
                      style: TextStyle(fontSize: 16),
                    ),
              SizedBox(width: 3),
              Icon(
                Icons.edit,
                semanticLabel: 'Edit',
                size: 15,
              )
            ]))
      ],
    );
  }

  Widget _buildTaskDescription(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }

        if(value.length >= 9000){
          return 'A lot to do, huh? Maybe a little less would help..';
        }

        _taskDescription = value;
        return null;
      },
      initialValue: _taskDescription,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: maxLengthOfTaskDescriptions,
      decoration: InputDecoration(
        labelText: 'Task description',
      ),
    );
  }

  Widget _editTaskButton(BuildContext context) {
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
          Container(
            width: kDefaultPrimaryButtonWidth,
            child: ElevatedButton(
              onPressed: () {
                submitEditTask(context);
              },
              child: Text('Edit Task'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _initialDate,
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(primary: kTitleTextColor),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child,
          );
        },
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void submitEditTask(BuildContext context) {
    if (_formKey.currentState.validate()) {
      DateTime date = _selectedDate ?? _initialDate;
      Task editedTask = Task(_taskToEdit.id, _taskDescription, _taskToEdit.isFinished, date);

      final taskCubit = BlocProvider.of<TaskCubit>(context);
      taskCubit.editTask(editedTask);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
            (Route<dynamic> route) => false,
        arguments: MainScreenArguments(editedTask.executionDate),
      );
    }
  }
}
