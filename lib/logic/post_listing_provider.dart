import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class PostListingProvider extends ChangeNotifier {
  PostListingProvider();

  final List<Uint8List> imageBytesList = [];
  final List<String> imagePaths = [];

  final Map<String, Object> postListingData = {};

  final picker = ImagePicker();

  bool canPickImage() => imageBytesList.length < 10;

  Future<void> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      imageBytesList.add(bytes);
      imagePaths.add(pickedImage.path);
    }
    notifyListeners();
  }

  void removeImage(int index) {
    imageBytesList.removeAt(index);
    imagePaths.removeAt(index);
    notifyListeners();
  }

  bool validatePostListingFields() {
    return true;
  }

  Future<void> postListing() async {
    final result = await ListingsServices().postListing(
      postListingData,
      imagePaths,
    );
  }
}
