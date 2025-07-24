import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:motorix_app/data/services/listings_services.dart';

class PostListingProvider extends ChangeNotifier {
  PostListingProvider();

  late String? errorMessage;

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

  Future<List<http.MultipartFile>> buildFiles(
    List<Uint8List> pickedImageBytes,
  ) {
    return Future.wait(
      pickedImageBytes.map((imageBytes) async {
        return http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: 'images',
        );
      }),
    );
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
    final images = await buildFiles(imageBytesList);
    postListingData['currentUserId'] = 'edd5a17b-aa0f-4317-9226-b6bd80acbd84';

    final result = await ListingsServices().postListing(
      postListingData,
      images,
    );

    if (!result.isSuccess) {
      // Show toast that the post listing failed
      errorMessage = result.error;
      return;
    }

    // Success show the user some feedback that the post of successful
  }
}
