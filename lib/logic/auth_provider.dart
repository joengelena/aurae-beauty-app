import 'package:flutter/material.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.signedOut;
  bool get isSignedIn => status == AuthStatus.signedIn;

  Future<void> signIn() async {
    status = AuthStatus.signedIn;
    notifyListeners();
  }

  Future<void> signOut() async {
    status = AuthStatus.signedOut;
    notifyListeners();
  }
}
