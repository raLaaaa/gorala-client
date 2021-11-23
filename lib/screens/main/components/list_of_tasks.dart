import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorala/bloc/cubits/task_cubit.dart';
import 'package:gorala/models/task.dart';
import 'package:gorala/screens/tasks/edit_task_view.dart';

import '../../../constants.dart';
import 'task_card.dart';

class ListOfTasks extends StatefulWidget {
  final List<Task> taskList;

  const ListOfTasks({
    Key key,
    @required this.taskList,
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
        child: ListView.builder(
          itemCount: widget.taskList.length,
          itemBuilder: (context, index) => TaskCard(
            task: widget.taskList[index],
            press: () {
              Navigator.pushNamed(
                context,
                '/edit',
                arguments: EditTaskArguments(widget.taskList[index]),
              );
            },
            toggleFinish: () {
              var localTask = widget.taskList[index];
              Task editedTask = Task(localTask.id, localTask.description, !localTask.isFinished, localTask.executionDate);

              setState(() {
                widget.taskList[index] = editedTask;
              });

              final taskCubit = BlocProvider.of<TaskCubit>(context);
              taskCubit.changeTaskStatusSeamless(editedTask);

            },
          ),
        ),
      ),
    );
  }
}
