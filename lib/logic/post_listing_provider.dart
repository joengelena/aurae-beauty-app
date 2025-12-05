import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motorix_app/data/exceptions/app_exception.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/data/services/listings_services.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';

class PostListingProvider extends ChangeNotifier
    implements ListingFormDataProvider {
  PostListingProvider() {
    _loadAttributes();
  }

  static const supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
  ];

  int? newListingId;
  bool isLoading = false;
  bool successfulPost = false;
  String errorMessage = '';
  @override
  List<ListingAttribute> listingAttributeOptions = [];
  final optionalDropdownFields = ['transmission', 'cylinders'];
  final List<Uint8List> imageBytesList = [];
  final List<String> imageNames = [];
  final Map<String, Object> postListingData = {};
  final picker = ImagePicker();
  bool canPickImage() => imageBytesList.length < 10;

  @override
  Map<String, Object> get formData => postListingData;

  Future<void> _loadAttributes() async {
    try {
      listingAttributeOptions = await ListingsServices().getListingAttributes();
      // Add 'None' option to optional dropdown fields
      for (var attributeWithoutNone in listingAttributeOptions) {
        if (optionalDropdownFields.contains(attributeWithoutNone.name)) {
          attributeWithoutNone.attributeValues.insert(0, 'None');
        }
      }
    } catch (e) {
      // Silently handle attribute loading errors
    } finally {
      notifyListeners();
    }
  }

  List<String> getAttributeValues(String attributeName) {
    try {
      return listingAttributeOptions
          .firstWhere((attr) => attr.name == attributeName)
          .attributeValues;
    } catch (e) {
      return [];
    }
  }

  Future<String?> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) {
      return null;
    }

    // Validate file extensions
    final extension = pickedImage.name.split('.').last.toLowerCase();
    if (!supportedImageExtensions.contains(extension)) {
      return 'Unsupported file type ".$extension"\n\n'
          'Please select an image with one of these formats:\n'
          '${supportedImageExtensions.map((e) => '.$e').join(', ')}';
    }

    final bytes = await pickedImage.readAsBytes();
    imageBytesList.add(bytes);
    imageNames.add(pickedImage.name);
    notifyListeners();

    return null;
  }

  MediaType _getMediaType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
      default:
        return MediaType('image', 'jpeg'); // Default fallback
    }
  }

  Future<List<http.MultipartFile>> buildFiles(
    List<Uint8List> pickedImageBytes,
  ) {
    return Future.wait(
      List.generate(pickedImageBytes.length, (index) async {
        final imageBytes = pickedImageBytes[index];
        final imageName = imageNames[index];
        return http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: imageName,
          contentType: _getMediaType(imageName),
        );
      }),
    );
  }

  void removeImage(int index) {
    imageBytesList.removeAt(index);
    imageNames.removeAt(index);
    notifyListeners();
  }

  bool validatePostListingFields() {
    return true;
  }

  void resetProvider() {
    newListingId = null;
    isLoading = false;
    successfulPost = false;
    errorMessage = '';
    imageBytesList.clear();
    imageNames.clear();
  }

  Future<void> postListing() async {
    isLoading = true;
    errorMessage = '';
    successfulPost = false;
    notifyListeners();

    try {
      final images = await buildFiles(imageBytesList);
      postListingData['currentUserId'] = 'edd5a17b-aa0f-4317-9226-b6bd80acbd84';

      final result = await ListingsServices().postListing(
        postListingData,
        images,
      );

      newListingId = result['listingId'] as int?;
      successfulPost = true;
    } catch (e) {
      if (e is AppException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Failed to post listing';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
