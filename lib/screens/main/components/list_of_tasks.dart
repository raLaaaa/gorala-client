import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/screens/tasks/edit_task_view.dart';

import '../../../constants.dart';
import 'task_card.dart';

class ListOfTasks extends StatefulWidget {
  final List<Task> openTasks;
  final List<Task> finishedTasks;

  const ListOfTasks({
    Key key,
    @required this.openTasks,
    @required this.finishedTasks,
  }) : super(key: key);

  @override
  _ListOfTasksState createState() => _ListOfTasksState();
}

class _ListOfTasksState extends State<ListOfTasks> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBgDarkColor,
      child: _buildListOfTasks(),
    );
  }

  Widget _buildListOfTasks() {
    return Container(
      padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
      child: SafeArea(
        right: false,
        child: ListView(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: widget.openTasks.length,
              itemBuilder: (context, index) => TaskCard(
                  task: widget.openTasks[index],
                  press: () {
                    _onPressItemFromOpen(index);
                  },
                  toggleFinish: () {
                    _finishTask(index);
                  }),
            ),
            Divider(),
            Text('FINISHED'),
            ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: widget.finishedTasks.length,
              itemBuilder: (context, index) => TaskCard(
                  task: widget.finishedTasks[index],
                  press: () {
                    _onPressItemFromFinish(index);
                  },
                  toggleFinish: () {
                    _openTask(index);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _onPressItemFromFinish(index) {
    Navigator.pushNamed(
      context,
      '/edit',
      arguments: EditTaskArguments(widget.finishedTasks[index]),
    );
  }

  void _onPressItemFromOpen(index) {
    Navigator.pushNamed(
      context,
      '/edit',
      arguments: EditTaskArguments(widget.openTasks[index]),
    );
  }

  void _finishTask(index) {
    var localTask = widget.openTasks[index];
    Task editedTask = Task(localTask.id, localTask.description, true, localTask.executionDate);

    setState(() {
      widget.finishedTasks.add(editedTask);
      widget.openTasks.removeAt(index);
    });

    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.changeTaskStatusSeamless(editedTask);
  }

  void _openTask(index) {
    var localTask = widget.finishedTasks[index];
    Task editedTask = Task(localTask.id, localTask.description, false, localTask.executionDate);

    setState(() {
      widget.openTasks.add(editedTask);
      widget.finishedTasks.removeAt(index);
    });

    final taskCubit = BlocProvider.of<TaskCubit>(context);
    taskCubit.changeTaskStatusSeamless(editedTask);
  }
}
