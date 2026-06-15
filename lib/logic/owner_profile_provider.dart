import 'package:flutter/material.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/user.dart';
import 'package:shine_app/data/services/dress_services.dart';
import 'package:shine_app/data/services/user_services.dart';

class OwnerProfileProvider extends ChangeNotifier {
  OwnerProfileProvider();

  User? owner;
  List<Listing> dresses = [];
  bool isLoading = false;
  bool hasError = false;

  Future<void> load(String userId) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final ownerFuture = UserServices().getUserWithId(userId);
      final dressesFuture = DressServices().getPublicDresses(
        allQueries: {'userId': userId, 'limit': '50'},
      );

      owner = await ownerFuture;
      final result = await dressesFuture;
      dresses = result.data;
    } catch (e) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    owner = null;
    dresses = [];
    isLoading = false;
    hasError = false;
    notifyListeners();
  }
}
