import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String userId;
  // String _token;
  // DateTime _expiryDate;

  Future<void> signup(String email, String password) async {
    const signUpURL =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAtkAyXB1CwfK6OXRnHq7ySlQb0UMbWEEA';
    final response = await http.post(
      signUpURL,
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    print(json.decode(response.body));
  }
}
