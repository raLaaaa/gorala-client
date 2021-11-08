import 'dart:convert';

import 'package:gorala/models/user.dart';
import 'package:gorala/services/api/api_client.dart';

class AuthRepository {
  static String AUTH_TOKEN = '';

  Future<User> login(String username, String password) async {
    var data = {'username': username, 'password': password};

    dynamic response = await ApiClient.postRequest('/login', data);

    if(response.statusCode == 400){
      return null;
    }

    var userMail = jsonDecode(response.body)['email'];
    var userID = jsonDecode(response.body)['id'];
    var userToken = jsonDecode(response.body)['token'];
    AUTH_TOKEN = userToken;

    return User(userMail, userID.toString(), userToken);
  }
}
