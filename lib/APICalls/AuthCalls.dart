import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthorizationCalls {
  String _url;
  var _client;

  AuthorizationCalls() {
    _url = dotenv.env['API_URL'];
    _client = http.Client();
  }

  Future<void> registerUser({
    String email,
    String password,
    bool isAdmin = false,
    String adminPassword = '',
  }) async {
    var bodyData = {
      "email": email,
      "password": password,
      "isAdmin": isAdmin,
      "adminPassword": adminPassword,
    };
    var response = await _client.post(
      Uri.parse(_url + 'signup'),
      body: jsonEncode(bodyData),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 7));
    var res = jsonDecode(response.body);
    if (res['error'])
      throw Exception(res['message']);
    else
      saveUserToken(tkn: res['userToken']);
  }

  Future<void> loginUser({String email, String password}) async {
    //print("Entered API CALL");
    var bodyData = {
      "email": email,
      "password": password,
    };
    var response = await _client.post(
      Uri.parse(_url + 'login'),
      body: jsonEncode(bodyData),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 7));
    //print(response.body);
    var res = jsonDecode(response.body);
    if (res['error'])
      throw Exception(res['message']);
    else
      saveUserToken(tkn: res['userToken']);
  }

  Future<dynamic> getUserDetails() async {
    var tkn = await retrieveUserToken();
    var response = await _client.get(
      Uri.parse(_url + 'user-details'),
      headers: {
        'Authorization': tkn,
        'Content-Type': 'application/json',
      },
    );
    var res = jsonDecode(response.body);
    if (res['error'])
      throw Exception(res['message']);
    else
      return res;
  }

  Future<void> upgradeUser({String adminPassword}) async {
    var tkn = await retrieveUserToken();
    var bodyData = {"adminPassword": adminPassword};
    var response = await _client.post(
      Uri.parse(_url + 'upgrade-account'),
      body: jsonEncode(bodyData),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': tkn,
      },
    );
    var res = jsonDecode(response.body);
    if (res['error']) throw Exception(res['message']);
  }

  Future<void> logOutUser() async {
    var tkn = await retrieveUserToken();
    var response = await _client.get(
      Uri.parse(_url + 'logout'),
      headers: {
        'Authorization': tkn,
        'Content-Type': 'application/json',
      },
    );
    var res = jsonDecode(response.body);
    if (res['error']) throw Exception(res['message']);
  }

  static Future<void> saveUserToken({String tkn}) async {
    FlutterSecureStorage fSS = FlutterSecureStorage();
    await fSS.write(key: 'token', value: tkn);
  }

  static Future<String> retrieveUserToken() async {
    FlutterSecureStorage fSS = FlutterSecureStorage();
    return await fSS.read(key: 'token');
  }

  static Future<void> deleteUserToken() async {
    FlutterSecureStorage fSS = FlutterSecureStorage();
    await fSS.delete(key: 'token');
  }
}
