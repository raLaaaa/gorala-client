import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/bloc/repositories/task_repository.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/responsive.dart';
import 'package:gorala/screens/loading/loading_screen.dart';
import 'package:intl/intl.dart';

import 'components/list_of_tasks.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key key,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _initialPage = 4775807;
  int _lazyLoadingThreshold = 0;
  int _lazyLoadingThresholdReachedRight = 1;
  int _lazyLoadingThresholdReachedLeft = 1;
  PageController _pageController;
  DateFormat _dateFormat;
  DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _initialPage);
    _dateFormat = DateFormat('dd.MM.yyyy');
    _currentSelectedDate = DateTime.now();

    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);
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
        title: Text(_dateFormat.format(_currentSelectedDate), style: TextStyle(fontSize: 28)),
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
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            _handlePageChange(index);
          },
          itemBuilder: (context, _index) {
            return BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TasksLoading) {
                  return LoadingView();
                } else if (state is TasksError) {
                  return Center(child: Text(state.message));
                } else if (state is TasksLoaded) {
                  DateTime dateToFetch = DateTime.now().toUtc();
                  dateToFetch = dateToFetch.add(Duration(days: _index - _initialPage));
                  DateTime roundedDate = DateTime(dateToFetch.year, dateToFetch.month, dateToFetch.day, 0, 0, 0, 0).toUtc();
                  var tasksForThisDay = state.tasks[roundedDate];

                  if (tasksForThisDay != null) {
                    return _buildEntryForPageController(tasksForThisDay);
                  } else {
                    return _buildEntryForPageController([]);
                  }
                } else {
                  return Text('this is a bug: ' + state.toString());
                }
              },
            );
          },
        ),
      ),
    );
  }

  _handlePageChange(int index) async {
    DateTime now = DateTime.now();
    DateTime newDate = now.add(Duration(days: index - _initialPage));
    int fetchRange = (int.parse(TaskRepository.LAZY_LOADING_FETCH_RANGE));
    int absTimesSwiped = ((index - _initialPage).abs());

    setState(() {
      _currentSelectedDate = newDate;
    });

    _lazyLoadingThreshold = ((index - _initialPage));

    if (_lazyLoadingThreshold >= (fetchRange * _lazyLoadingThresholdReachedRight)) {
      _lazyLoadingThresholdReachedRight += 1;
      final taskCubit = BlocProvider.of<TaskCubit>(context);
      taskCubit.getAllTasksOfUserByDateWithRange(newDate);
    } else if (_lazyLoadingThreshold <= ((fetchRange * -1) * _lazyLoadingThresholdReachedLeft)) {
      _lazyLoadingThresholdReachedLeft += 1;
      final taskCubit = BlocProvider.of<TaskCubit>(context);
      taskCubit.getAllTasksOfUserByDateWithRange(newDate);
    }
  }

  Widget _buildEntryForPageController(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(child: Text("No tasks yet"));
    }

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
    taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);
  }
}
