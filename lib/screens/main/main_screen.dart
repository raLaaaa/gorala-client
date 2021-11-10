import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/responsive.dart';
import 'package:gorala/screens/loading/loading_screen.dart';
import 'package:intl/intl.dart';

import 'components/list_of_tasks.dart';

class MainScreen extends StatefulWidget {
  // Press "Command + ."
  const MainScreen({
    Key key,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int _initialPage = 4775807;
  PageController _pageController;
  DateFormat _dateFormat;
  DateTime _currentSelectedDate;

  @override
  void initState() {
    _pageController = PageController(initialPage: _initialPage);
    _dateFormat = DateFormat('dd.MM.yyyy');
    _currentSelectedDate = DateTime.now();

    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getAllTasksOfUser();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dateFormat.format(_currentSelectedDate),
            style: TextStyle(fontSize: 28)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return _refreshTasks(context);
        },
        child: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TasksEmpty) {
              return Center(child: Text('No tasks found for today'));
            } else if (state is TasksLoading) {
              return LoadingView();
            } else if (state is TasksError) {
              return Center(child: Text(state.message));
            } else if (state is TasksLoaded) {
              return PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  updateDate(index);
                },
                itemBuilder: (context, _index) {
                  return _buildEntryForPageController(state.tasks);
                },
              );
            } else {
              return Text('this is a bug');
            }
          },
        ),
      ),
    );
  }

  updateDate(int index) {
    DateTime now = DateTime.now();

    setState(() {
      _currentSelectedDate = now.add(Duration(days: index - _initialPage));
    });
  }

  Widget _buildEntryForPageController(List<Task> tasks) {
    return Responsive(
      mobile: ListOfTasks(
        taskList: tasks,
      ),
      tablet: Row(
        children: [
          Expanded(
            flex: 6,
            child: ListOfTasks(
              taskList: tasks,
            ),
          ),
        ],
      ),
      desktop: Row(
        children: [
          Expanded(
            child: ListOfTasks(
              taskList: tasks,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.logout();
  }

  Future<void> _refreshTasks(BuildContext context) async {
    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getAllTasksOfUser();
  }
}
