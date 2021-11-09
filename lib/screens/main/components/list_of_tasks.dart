import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/auth_cubit.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/models/Email.dart';
import 'package:gorala/responsive.dart';
import 'package:gorala/screens/loading/loading_screen.dart';

import '../../../constants.dart';
import 'task_card.dart';

class ListOfTasks extends StatefulWidget {
  // Press "Command + ."
  const ListOfTasks({
    Key key,
  }) : super(key: key);

  @override
  _ListOfTasksState createState() => _ListOfTasksState();
}

class _ListOfTasksState extends State<ListOfTasks> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getTasksOfUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: RefreshIndicator(
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
                return _buildListOfTasks(state);
              } else {
                return Text('this is a bug');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListOfTasks(TasksLoaded tasksLoaded) {
    return Container(
      padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
      color: kBgDarkColor,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Row(
                children: [
                  if (!Responsive.isDesktop(context)) SizedBox(width: 5),
                  Expanded(
                      child: Text(
                    '21.10.2021',
                    style: TextStyle(fontSize: 28),
                  )),
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
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: tasksLoaded.tasks.length,
                // On mobile this active dosen't mean anything
                itemBuilder: (context, index) => TaskCard(
                  task: tasksLoaded.tasks[index],
                  press: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    authCubit.logout();
  }

  Future<void> _refreshTasks(BuildContext context) async {
    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.getTasksOfUser();
  }
}
