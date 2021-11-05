import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class ApiClient {
  static final String baseUrl = DotEnv().env['SERVER'];
  static final Duration timeOutDuration = const Duration(seconds: 50);
  static final Client httpClient = http.Client();

  static Future<http.Response> getRequest(String url) async {
    return Future.sync(() async {
      Response response;

      try {
        var uri = Uri.parse(baseUrl + url);
        if (AuthenticationService.authToken.isEmpty) {
          response = await http.get(uri).timeout(timeOutDuration);
        } else {
          response = await http.get(uri, headers: {
            'Authorization': 'Token ' + AuthenticationService.authToken,

          }).timeout(timeOutDuration);
        }
      } on TimeoutException catch (e) {

        return null;
      } on SocketException catch (e) {

        return null;
      }

      if (response != null) {
        checkResponseCode(response.statusCode, response.body, url, 'GET');
      } else {
        throw Exception('Response was null for GET ' + url);
      }

      return response;
    });
  }

  static Future<http.Response> postRequest(String url, Object data) async {
    return Future.sync(() async {
      Response response;

      try {
        var uri = Uri.parse(baseUrl + url);
        if (AuthenticationService.authToken.isEmpty) {
          response = await http.post(uri, body: data).timeout(timeOutDuration);
        } else {
          response = await http.post(uri, body: data, headers: {
            'Authorization': 'Token ' + AuthenticationService.authToken,
          }).timeout(timeOutDuration);
        }
      } on TimeoutException catch (e) {

        return null;
      } on SocketException catch (e) {

        return null;
      }

      if (response != null) {
        checkResponseCode(response.statusCode, response.body, url, 'POST');
      } else {
        throw Exception('Response was null for POST ' + url);
      }

      return response;
    });
  }

  static Future<http.Response> putRequest(String url, Object data) async {
    return Future.sync(() async {
      Response response;

      try {
        var uri = Uri.parse(baseUrl + url);
        response = await http.put(uri, body: data, headers: {
          'Authorization': 'Token ' + AuthenticationService.authToken,
        }).timeout(timeOutDuration);
      } on TimeoutException catch (e) {

        return null;
      }

      if (response != null) {
        checkResponseCode(response.statusCode, response.body, url, 'PUT');
      } else {
        throw Exception('Response was null for PUT' + url);
      }
      return response;
    });
  }

  static dynamic deleteRequest(String url) async {
    return Future.sync(() async {
      Response response;

      try {
        var uri = Uri.parse(baseUrl + url);
        response = await http.delete(uri, headers: {
          'Authorization': 'Token ' + AuthenticationService.authToken,

        }).timeout(timeOutDuration);
      } on TimeoutException catch (e) {


        return null;
      } on SocketException catch (e) {


        return null;
      }

      if (response != null) {
        checkResponseCode(response.statusCode, response.body, url, 'DELETE');
      } else {
        throw Exception('Response was null for DELETE' + url);
      }

      return response;
    });
  }

  static void checkResponseCode(
      int code, String responseBody, String url, String type) {
    if (code != 200) {
      if (code == 401) {
        print('Not Authorized: ' +
            code.toString() +
            ' | ' +
            responseBody +
            ' | URL: ' +
            url +
            ' | TYPE: ' +
            type);

    }
  }
}
