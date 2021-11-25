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

class _ListOfTasksState extends State<ListOfTasks> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool _hideFinishTasks = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      upperBound: 0.5,
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
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
            widget.finishedTasks.isNotEmpty ? Divider() : SizedBox(),
            widget.finishedTasks.isNotEmpty ? SizedBox(child: _buildFinishedTasksHeadline()) : SizedBox(),
            !_hideFinishTasks
                ? ListView.builder(
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
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedTasksHeadline() {
    return InkWell(
      onTap: () {
        setState(() {
          {
            setState(() {
              if (_hideFinishTasks) {
                _animationController..reverse(from: 0.5);
              } else {
                _animationController..forward(from: 0.0);
              }
              _hideFinishTasks = !_hideFinishTasks;
            });
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: kDefaultPadding, top: kDefaultPadding / 5, bottom: kDefaultPadding / 5, right: kDefaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: kDefaultPadding-5, right: kDefaultPadding, top: kDefaultPadding - 7, bottom: kDefaultPadding - 7),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.80),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                    child: Icon(Icons.expand_more, color: Colors.white),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Finished Tasks ' + widget.finishedTasks.length.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
