import 'dart:convert';

import 'package:gorala/models/task.dart';
import 'package:gorala/services/api/api_client.dart';

class TaskRepository {
  Future<List<Task>> fetchTasksOfUser() async {
    dynamic response = await ApiClient.getRequest('/api/v1/tasks');
    List<Task> toReturn = [];

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);

      print(decodedBody);

      decodedBody.forEach((entry) => toReturn.add(Task(entry['ID'].toString(),
          entry['Description'], DateTime(1))));

      return toReturn;
    }
    else{
      return null;
    }
  }
}
