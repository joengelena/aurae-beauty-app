import 'package:flutter/material.dart';

class BackButtonProvider extends ChangeNotifier {
  final List<String> _routeStack = [];

  List<String> get routeStack => List.unmodifiable(_routeStack);
  bool get hasHistory => _routeStack.isNotEmpty;

  /// Push the current route onto the stack before navigating to a nested page
  void pushRoute(String route) {
    _routeStack.add(route);
    notifyListeners();
  }

  /// Pop and return the last route from the stack
  String? popRoute() {
    if (_routeStack.isEmpty) return null;
    final route = _routeStack.removeLast();
    notifyListeners();
    return route;
  }

  /// Reset the route stack (called when navigating via bottom nav)
  void reset() {
    _routeStack.clear();
    notifyListeners();
  }
}
