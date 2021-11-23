import 'dart:convert';

import 'package:gorala/models/task.dart';
import 'package:gorala/services/api/api_client.dart';
import 'package:intl/intl.dart';

class TaskRepository {

  static final LAZY_LOADING_FETCH_RANGE = '10';

  Future<Map<DateTime, List<Task>>> fetchAllTasksOfUser() async {
    dynamic response = await ApiClient.getRequest('/api/v1/tasks');

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      return _convertResponseToMap(decodedBody);
    } else {
      return null;
    }
  }

  Future<Map<DateTime, List<Task>>> fetchAllTasksOfUserByDate(DateTime time) async {
    DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
    dynamic response = await ApiClient.getRequest('/api/v1/tasks/' + _dateFormat.format(time));

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      return _convertResponseToMap(decodedBody);
    } else {
      return null;
    }
  }

  Future<Map<DateTime, List<Task>>> fetchAllTasksOfUserByDateWithRange(DateTime time) async {
    var _dateFormat = DateFormat('dd-MM-yyyy');

    dynamic response = await ApiClient.getRequest(
        '/api/v1/tasks/' + _dateFormat.format(time) + '/' + LAZY_LOADING_FETCH_RANGE);


    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      return _convertResponseToMap(decodedBody);
    } else {
      return null;
    }
  }

  Future<Task> createTask(Task task) async {
    dynamic data = {
      "description": task.description,
      "executionDate": task.executionDate.toUtc().toIso8601String(),
    };

    dynamic response = await ApiClient.postRequestAsJSON(
        '/api/v1/tasks/add', jsonEncode(data));

    if(response.statusCode == 201) {
      var decodedBody = jsonDecode(response.body);

      Task task =Task(
        decodedBody['ID'].toString(),
        decodedBody['Description'],
        decodedBody['IsFinished'],
        DateTime.parse(decodedBody['ExecutionDate']),
      );

      return task;
    } else {
    return null;
    }
  }

  Future<Task> editTask(Task task) async {
    dynamic data = {
      "description": task.description,
      "executionDate": task.executionDate.toUtc().toIso8601String(),
      "isFinished": task.isFinished
    };

     dynamic response = await ApiClient.putRequest(
        '/api/v1/tasks/edit/'+task.id, jsonEncode(data));

    if(response.statusCode == 201) {
      var decodedBody = jsonDecode(response.body);
      Task task =Task(
        decodedBody['ID'].toString(),
        decodedBody['Description'],
        decodedBody['IsFinished'],
        DateTime.parse(decodedBody['ExecutionDate']),
      );

      return task;
    } else {
      return null;
    }
  }

  Future<bool> deleteTask(Task task) async {

    dynamic response = await ApiClient.deleteRequest(
        '/api/v1/tasks/delete/'+task.id);

    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Map<DateTime, List<Task>> _convertResponseToMap(decodedBody) {
    Map<DateTime, List<Task>> toReturn = Map();

    if (decodedBody.length == 0) {
      return null;
    }

    decodedBody.forEach((entry) {
      List<Task> list = toReturn[DateTime.parse(entry['ExecutionDate'])];

      if (list == null) {
        toReturn[DateTime.parse(entry['ExecutionDate'])] = [];
        toReturn[DateTime.parse(entry['ExecutionDate'])].add(
          Task(
            entry['ID'].toString(),
            entry['Description'],
            entry['IsFinished'],
            DateTime.parse(entry['ExecutionDate']),
          ),
        );
      } else {
        toReturn[DateTime.parse(entry['ExecutionDate'])].add(
          Task(
            entry['ID'].toString(),
            entry['Description'],
            entry['IsFinished'],
            DateTime.parse(entry['ExecutionDate']),
          ),
        );
      }
    });



    return toReturn;
  }
}
