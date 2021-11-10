import 'dart:convert';

import 'package:gorala/models/user.dart';
import 'package:gorala/services/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static String AUTH_TOKEN = '';

  Future<User> login(String username, String password) async {
    var data = {'username': username, 'password': password};

    dynamic response = await ApiClient.postRequest('/login', data);

    if(response.statusCode != 200){
      return null;
    }

    var userMail = jsonDecode(response.body)['email'];
    var userID = jsonDecode(response.body)['id'];
    var userToken = jsonDecode(response.body)['token'];
    AUTH_TOKEN = userToken;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('AUTH_TOKEN', AUTH_TOKEN);
    await prefs.setString('EMAIL', userToken);
    await prefs.setString('ID', userID.toString());

    return User(userMail, userID.toString(), userToken);
  }

  Future<bool> checkLogin() async {
    dynamic response = await ApiClient.getRequest('/api/v1/checklogin');

    if(response.statusCode == 200){
      return true;
    }
    else{
      return false;
    }
  }
}
