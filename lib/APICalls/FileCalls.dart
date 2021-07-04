import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inkling_personal/APICalls/AuthCalls.dart';

class FileCalls {
  FirebaseStorage _firebaseStorage;
  String _url;
  var _client;
  FileCalls() {
    _firebaseStorage = FirebaseStorage.instance;
    _url = dotenv.env['API_URL'];
    _client = http.Client();
  }

  Future<dynamic> getUserFileData() async {
    var tkn = await AuthorizationCalls.retrieveUserToken();
    var response = await _client.get(
      Uri.parse(_url + 'get-user-documents'),
      headers: {
        'Authorization': tkn,
        'Content-Type': 'application.json',
      },
    );
    var res = jsonDecode(response.body);
    if (res['error'])
      throw Exception(res['message']);
    else
      return res;
  }

  Future<void> addFileToUser({@required String fileName}) async {
    var tkn = await AuthorizationCalls.retrieveUserToken();
    var bodyData = {'fileName': fileName};
    var response = await _client.post(
      Uri.parse(_url + 'post-user-document'),
      body: jsonEncode(bodyData),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': tkn,
      },
    );
    var res = jsonDecode(response.body);
    if (res['error']) throw Exception(res['message']);
  }

  Future<dynamic> getStoreFileData() async {
    var response = await _client.get(
      Uri.parse(_url + 'get-store-documents'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    var res = jsonDecode(response.body);
    if (res['error'])
      throw Exception(res['message']);
    else
      return res;
  }

  Future<void> addFileToStore({
    String fileName,
    double filePrice,
    String adminPassword,
  }) async {
    var bodyData = {
      'fileName': fileName,
      'filePrice': filePrice,
      'adminPassword': adminPassword
    };
    var response = await _client.post(
      Uri.parse(_url + 'post-store-document'),
      body: jsonEncode(bodyData),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    var res = jsonDecode(response.body);
    if (res['error']) throw Exception(res['message']);
  }

  Future<String> getPDFFile({@required String fileName}) async {
    if (fileName.isEmpty) throw Exception('No File Name Provided');
    var _ref = _firebaseStorage.ref().child('Files').child(fileName);
    String url = (await _ref.getDownloadURL()).toString();
    //print(url);
    return url;
  }

  Future<void> uploadTask({String fileVl, String fileName}) async {
    if (fileVl != null) {
      var _ref = _firebaseStorage.ref().child('Files').child(fileName);
      await _ref.putFile(File(fileVl));
    } else
      throw Exception("Error Occured While Uploading. Try Again");
  }
}
