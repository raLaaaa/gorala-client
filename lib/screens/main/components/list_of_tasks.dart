import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gorala/models/task.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: _buildListOfTasks(),
      ),
    );
  }

  Widget _buildListOfTasks() {
    return Container(
      padding: EdgeInsets.only(top: kIsWeb ? kDefaultPadding : 0),
      color: kBgDarkColor,
      child: SafeArea(
        right: false,
        child: ListView.builder(
          itemCount: widget.taskList.length,
          // On mobile this active dosen't mean anything
          itemBuilder: (context, index) => TaskCard(
            task: widget.taskList[index],
            press: () {},
          ),
        ),
      ),
    );
  }
}
