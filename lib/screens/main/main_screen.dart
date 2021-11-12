import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/bloc/repositories/task_repository.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/responsive.dart';
import 'package:gorala/screens/loading/loading_screen.dart';
import 'package:gorala/screens/tasks/create_task_view.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import 'components/list_of_tasks.dart';

class MainScreenArguments {
  final DateTime initalDate;

  MainScreenArguments(this.initalDate);
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key key,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int _initialPage = 4775807;
  int _lazyLoadingThreshold = 0;
  int _lazyLoadingThresholdReachedRight = 1;
  int _lazyLoadingThresholdReachedLeft = 1;
  int _indexDiffToDate = 0;
  bool _hasBeenNavigatedByArgs;
  bool _usePostFrameCallBack = false;
  PageController _pageController;
  DateFormat _dateFormat;
  DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _initialPage);
    _dateFormat = DateFormat('dd.MM.yyyy');
    _currentSelectedDate = DateTime.now();
    _hasBeenNavigatedByArgs = false;

    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAutoNavigate(context);
      if (_usePostFrameCallBack && _indexDiffToDate != 0) {
        _pageController.jumpToPage(_initialPage + _indexDiffToDate);
      }
    });
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
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add',
                arguments: CreateTaskArguments(_currentSelectedDate),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          _handlePageChange(index);
        },
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, _index) {
          return RefreshIndicator(
            color: kTitleTextColor,
            onRefresh: () {
              return _refreshTasks(context);
            },
            child: BlocBuilder<TaskCubit, TaskState>(
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
            ),
          );
        },
      ),
    );
  }

  void _checkIfAutoNavigate(context) {
    var args = ModalRoute.of(context).settings.arguments as MainScreenArguments;
    if (args != null && args.initalDate != null && !_hasBeenNavigatedByArgs) {
      DateTime nowFull = DateTime.now().toUtc();
      DateTime now = DateTime(nowFull.year, nowFull.month, nowFull.day, 0, 0, 0, 0);
      DateTime clearedTime = DateTime(args.initalDate.year, args.initalDate.month, args.initalDate.day);

      _indexDiffToDate = clearedTime.difference(now).inDays;

      _usePostFrameCallBack = true;
      _hasBeenNavigatedByArgs = true;
    }
  }

  _handlePageChange(int index) async {
    DateTime now = DateTime.now();
    DateTime newDate = now.add(Duration(days: index - _initialPage));
    int fetchRange = (int.parse(TaskRepository.LAZY_LOADING_FETCH_RANGE));

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
      return Container(color: kBgDarkColor, child: _buildIfTasksEmpty());
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

  Widget _buildIfTasksEmpty() {
    return Center(
        child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No tasks found',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Container(
              decoration: BoxDecoration(
                color: kTitleTextColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(24.0),
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.add),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/add',
                    arguments: CreateTaskArguments(_currentSelectedDate),
                  );
                },
              )),
        ],
      ),
    ));
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
