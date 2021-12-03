import 'dart:convert';

import 'package:gorala/models/task.dart';
import 'package:gorala/services/api/api_client.dart';
import 'package:intl/intl.dart';

class TaskRepository {
  static final LAZY_LOADING_FETCH_RANGE = '10';
  static final ALL_CACHED_CARRY_ON_TASKS = Set<Task>();

  Future<Map<DateTime, List<Task>>> fetchAllTasksOfUser() async {
    dynamic response = await ApiClient.getRequest('/api/v1/tasks');

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      var defaultMap = _convertResponseToMap(decodedBody);

      _checkCarryOnTasks(defaultMap);

      return defaultMap;
    } else {
      return null;
    }
  }

  Future<Map<DateTime, List<Task>>> fetchAllTasksOfUserByDate(DateTime time) async {
    DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
    dynamic response = await ApiClient.getRequest('/api/v1/tasks/' + _dateFormat.format(time));

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      var defaultMap = _convertResponseToMap(decodedBody);

      _checkCarryOnTasks(defaultMap);

      return defaultMap;
    } else {
      return null;
    }
  }

  Future<Map<DateTime, List<Task>>> fetchAllTasksOfUserByDateWithRange(DateTime time) async {
    var _dateFormat = DateFormat('dd-MM-yyyy');

    dynamic response = await ApiClient.getRequest('/api/v1/tasks/' + _dateFormat.format(time) + '/' + LAZY_LOADING_FETCH_RANGE);

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      var defaultMap = _convertResponseToMap(decodedBody);

      _checkCarryOnTasks(defaultMap);

      return defaultMap;
    } else {
      return null;
    }
  }

  Future<Task> createTask(Task task) async {
    dynamic data = {
      "description": task.description,
      "isCarryOnTask": task.isCarryOnTask,
      "executionDate": task.executionDate.toUtc().toIso8601String(),
    };

    dynamic response = await ApiClient.postRequestAsJSON('/api/v1/tasks/add', jsonEncode(data));

    if (response.statusCode == 201) {
      var decodedBody = jsonDecode(response.body);

      Task task = Task(
        decodedBody['ID'].toString(),
        decodedBody['Description'],
        decodedBody['IsFinished'],
        decodedBody['IsCarryOnTask'],
        DateTime.parse(decodedBody['ExecutionDate']),
        DateTime.parse(decodedBody['CreatedAt']),
      );

      if (task.isCarryOnTask) {
        ALL_CACHED_CARRY_ON_TASKS.add(task);
      } else {
        ALL_CACHED_CARRY_ON_TASKS.removeWhere((element) => task.id == element.id);
      }

      return task;
    } else {
      return null;
    }
  }

  Future<Task> editTask(Task task) async {
    dynamic data = {
      "description": task.description,
      "executionDate": task.executionDate.toUtc().toIso8601String(),
      "isCarryOnTask": task.isCarryOnTask,
      "isFinished": task.isFinished
    };

    dynamic response = await ApiClient.putRequest('/api/v1/tasks/edit/' + task.id, jsonEncode(data));

    if (response.statusCode == 201) {
      var decodedBody = jsonDecode(response.body);
      Task task = Task(
        decodedBody['ID'].toString(),
        decodedBody['Description'],
        decodedBody['IsFinished'],
        decodedBody['IsCarryOnTask'],
        DateTime.parse(decodedBody['ExecutionDate']),
        DateTime.parse(decodedBody['CreatedAt']),
      );

      if (task.isCarryOnTask) {
        ALL_CACHED_CARRY_ON_TASKS.removeWhere((element) => task.id == element.id);
        ALL_CACHED_CARRY_ON_TASKS.add(task);

      } else {
        ALL_CACHED_CARRY_ON_TASKS.removeWhere((element) => task.id == element.id);
      }

      return task;
    } else {
      return null;
    }
  }

  Future<bool> deleteTask(Task task) async {
    dynamic response = await ApiClient.deleteRequest('/api/v1/tasks/delete/' + task.id);
    ALL_CACHED_CARRY_ON_TASKS.removeWhere((element) => task.id == element.id);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Map<DateTime, List<Task>> _convertResponseToMap(decodedBody) {
    Map<DateTime, List<Task>> toReturn = Map();

    if (decodedBody.length == 0) {
      return toReturn;
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
            entry['IsCarryOnTask'],
            DateTime.parse(entry['ExecutionDate']),
            DateTime.parse(entry['CreatedAt']),
          ),
        );
      } else {
        toReturn[DateTime.parse(entry['ExecutionDate'])].add(
          Task(
            entry['ID'].toString(),
            entry['Description'],
            entry['IsFinished'],
            entry['IsCarryOnTask'],
            DateTime.parse(entry['ExecutionDate']),
            DateTime.parse(entry['CreatedAt']),
          ),
        );
      }
    });

    return toReturn;
  }

  void _checkCarryOnTasks(
    Map<DateTime, List<Task>> defaultMap,
  ) {
    defaultMap.forEach((date, tasks) {
      tasks.forEach((task) {
        if (task.isCarryOnTask && !task.isFinished) {
          ALL_CACHED_CARRY_ON_TASKS.add(task);
        }
      });
    });
  }
}
