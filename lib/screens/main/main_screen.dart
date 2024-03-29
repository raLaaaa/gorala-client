import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/bloc/repositories/task_repository.dart';
import 'package:gorala/components/draw_triangle.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/responsive.dart';
import 'package:gorala/screens/tasks/create_task_view.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import 'components/list_of_tasks.dart';

class MainScreenArguments {
  final DateTime initalDate;

  MainScreenArguments(this.initalDate);
}

class MainScreen extends StatefulWidget {
  final MainScreenArguments args;

  const MainScreen({
    Key key,
    this.args,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int _initialPage = 4775807;
  int _currentIndex;

  Set<int> _loadedRanges;
  int _stepsWentLeft = 0;
  int _stepsWentRight = 0;

  int _indexDiffToDate = 0;
  bool _hasBeenNavigatedByArgs;
  bool _usePostFrameCallBackByArgNav = false;
  PageController _pageController;
  DateFormat _dateFormatHeadline;
  DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();

    _loadedRanges = Set();
    _pageController = PageController(initialPage: _initialPage);
    _dateFormatHeadline = DateFormat('E, dd.MM.yyyy');

    DateTime nowFull = DateTime.now();
    DateTime now = DateTime(nowFull.year, nowFull.month, nowFull.day, 0, 0, 0, 0);
    _currentSelectedDate = now;
    _hasBeenNavigatedByArgs = false;

    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);

    _loadedRanges.add(_initialPage);
    _currentIndex = _initialPage;

    _setupPostFrameCallBack(taskCubit);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        highlightElevation: 0,
        elevation: 0,
        foregroundColor: Colors.white,
        tooltip: 'Create a new task',
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add',
            arguments: CreateTaskArguments(_currentSelectedDate),
          );
        },
        backgroundColor: kTitleTextColor,
        child: Icon(
          Icons.add,
        ),
      ),
      appBar: AppBar(
        title: InkWell(
          onTap: onHeaderDateTap,
          child: Row(
            children: [
              Expanded(child: Text(_dateFormatHeadline.format(_currentSelectedDate), style: TextStyle(fontSize: 28))),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Calender view',
            icon: Icon(Icons.calendar_today),
            onPressed: _onCalendarTap
          ),
          kIsWeb
              ? SizedBox(
                  width: 5,
                )
              : SizedBox(width: 0),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'About', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        color: kBgDarkColor,
        child: PageView.builder(
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
                    return Center(child: CircularProgressIndicator());
                  } else if (state is TasksError) {
                    return Center(child: Text(state.message));
                  } else if (state is TasksLoaded) {
                    DateTime dateToFetch = DateTime.now();
                    dateToFetch = dateToFetch.add(Duration(days: _index - _initialPage));
                    DateTime roundedDate = DateTime(dateToFetch.year, dateToFetch.month, dateToFetch.day, 0, 0, 0, 0);

                    var allTasksForThisDay = state.tasks[roundedDate];
                    var openTasksForThisDay = <Task>[];
                    var finishedTasksForThisDay = <Task>[];

                    if (allTasksForThisDay != null) {
                      openTasksForThisDay = allTasksForThisDay.where((task) => !task.isFinished).toList();
                      finishedTasksForThisDay = allTasksForThisDay.where((task) => task.isFinished).toList();
                    }

                    TaskRepository.ALL_CACHED_CARRY_ON_TASKS.forEach((task) {
                      Task contains = openTasksForThisDay.firstWhereOrNull((element) => element.id == task.id);
                      if (contains == null && !task.isFinished && (task.executionDate.isAtSameMomentAs(dateToFetch) || dateToFetch.isAfter(task.executionDate))) {
                        openTasksForThisDay.add(task);
                      }
                    });

                    return Stack(
                      children: [
                        kIsWeb && _index == _currentIndex ? _buildLeftButtonForWeb() : SizedBox(),
                        kIsWeb && _index == _currentIndex ? _buildRightButtonForWeb() : SizedBox(),
                        _buildEntryForPageController(openTasksForThisDay, finishedTasksForThisDay)
                      ],
                    );
                  } else {
                    return Text('this is a bug: ' + state.toString());
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'About':
        _showAboutDialogue();
        break;
      case 'Logout':
        _logout(context);
        break;
      case 'Settings':
        break;
    }
  }

  Widget _buildLeftButtonForWeb() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: kTitleTextColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
            ),
            child: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
                tooltip: 'Previous page',
                onPressed: () {
                  setState(() {
                    _pageController.previousPage(duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                  });
                }),
          )),
    );
  }

  Widget _buildRightButtonForWeb() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
            decoration: BoxDecoration(
              color: kTitleTextColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
            ),
            child: IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
                tooltip: 'Next page',
                onPressed: () {
                  setState(() {
                    _pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                  });
                })),
      ),
    );
  }

  void _setupPostFrameCallBack(TaskCubit taskCubit) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAutoNavigate(context);
      if (_usePostFrameCallBackByArgNav && _indexDiffToDate != 0) {
        int newIndex = _initialPage + _indexDiffToDate;
        _pageController.jumpToPage(newIndex);
        taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);
        _loadedRanges.add(newIndex);
      }
    });
  }

  void _showAboutDialogue() {
    showAboutDialog(
        context: context,
        applicationName: 'gorala',
        applicationIcon: Triangle(width: 54, height: 54),
        applicationVersion: '1.0.0',
        children: [
          Link(
            uri: Uri.parse(
                'https://about.gorala.icu/'),
            target: LinkTarget.blank,
            builder: (BuildContext ctx, FollowLink openLink) {
              return TextButton.icon(
                onPressed: openLink,
                label: const Text('https://about.gorala.icu/'),
                icon: const Icon(Icons.read_more),
              );
            },
          ),
        ]
    );
  }

  void _checkIfAutoNavigate(context) {
    var args = widget.args;
    if (args != null && args.initalDate != null && !_hasBeenNavigatedByArgs) {
      DateTime nowFull = DateTime.now();
      DateTime now = DateTime(nowFull.year, nowFull.month, nowFull.day, 0, 0, 0, 0);
      DateTime clearedTime = DateTime(args.initalDate.year, args.initalDate.month, args.initalDate.day);

      _indexDiffToDate = clearedTime.difference(now).inDays;

      _usePostFrameCallBackByArgNav = true;
      _hasBeenNavigatedByArgs = true;
    }
  }

  _handlePageChange(int index) async {
    DateTime now = DateTime.now();
    DateTime newDate = now.add(Duration(days: index - _initialPage));
    int fetchRange = (int.parse(TaskRepository.LAZY_LOADING_FETCH_RANGE));
    final taskCubit = BlocProvider.of<TaskCubit>(context);

    setState(() {
      _currentSelectedDate = newDate;
    });

    if (index > _currentIndex) {
      _stepsWentRight += 1;
      _stepsWentLeft -= 1;

      if (_stepsWentRight >= fetchRange) {
        _stepsWentRight = 0;

        if (!_loadedRanges.contains(index)) {
          _loadedRanges.add(index);
          taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);
        }
      }
    } else if (index < _currentIndex) {
      _stepsWentLeft += 1;
      _stepsWentRight -= 1;

      if (_stepsWentLeft >= fetchRange) {
        _stepsWentLeft = 0;

        if (!_loadedRanges.contains(index)) {
          _loadedRanges.add(index);
          taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);
        }
      }
    }

    _currentIndex = index;
  }

  Widget _buildEntryForPageController(List<Task> openTasks, List<Task> finishedTasks) {
    if (openTasks.isEmpty && finishedTasks.isEmpty) {
      return Container(child: _buildIfTasksEmpty());
    }

    return Center(
      child: Container(
        width: kIsWeb ? 900 : MediaQuery.of(context).size.width,
        child: Responsive(
          mobile: ListOfTasks(
            openTasks: openTasks,
            finishedTasks: finishedTasks,
            currentlyViewedDate: _currentSelectedDate,
          ),
          tablet: Row(
            children: [
              Expanded(
                flex: 6,
                child: ListOfTasks(
                  openTasks: openTasks,
                  finishedTasks: finishedTasks,
                  currentlyViewedDate: _currentSelectedDate,
                ),
              ),
            ],
          ),
          desktop: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: 1400,
                  child: ListOfTasks(
                    openTasks: openTasks,
                    finishedTasks: finishedTasks,
                    currentlyViewedDate: _currentSelectedDate,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            'No tasks found today',
            style: TextStyle(fontSize: 17),
          ),
        ],
      ),
    ));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _currentSelectedDate,
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
    if (picked != null && picked != _currentSelectedDate)
      setState(() {
        _currentSelectedDate = picked;

        DateTime nowFull = DateTime.now();
        DateTime now = DateTime(nowFull.year, nowFull.month, nowFull.day, 0, 0, 0, 0);
        DateTime clearedTime = DateTime(_currentSelectedDate.year, _currentSelectedDate.month, _currentSelectedDate.day);

        _indexDiffToDate = clearedTime.difference(now).inDays;
        int newIndex = _initialPage + _indexDiffToDate;
        _pageController.jumpToPage(newIndex);
        final taskCubit = BlocProvider.of<TaskCubit>(context);
        taskCubit.getAllTasksOfUserByDateWithRange(_currentSelectedDate);
        _loadedRanges.add(newIndex);
      });
  }

  Future<void> _logout(BuildContext context) async {
    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.clearCachedTasks();

    final authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.logout();
  }

  Future<void> _refreshTasks(BuildContext context) async {
    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getAllTasksOfUserByDateWithRangeForReload(_currentSelectedDate);

    _stepsWentLeft = 0;
    _stepsWentRight = 0;
    _loadedRanges.clear();
  }

  void _onCalendarTap() {
    setState(() {
      _selectDate(context);
    });
  }

  void onHeaderDateTap() {
    _pageController.jumpToPage(_initialPage);
    _refreshTasks(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Jumped to todays date"),
      duration: Duration(seconds: 4),
    ));
  }
}
