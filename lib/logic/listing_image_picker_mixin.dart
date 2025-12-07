import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

/// Mixin that provides image picking and handling functionality for listing forms.
///
/// Used by both [PostListingProvider] and [EditListingProvider] to avoid
/// code duplication for common image operations.
mixin ListingImagePickerMixin {
  static const supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
  ];

  static const int maxImages = 10;

  final List<Uint8List> imageBytesList = [];
  final List<String> imageNames = [];
  final ImagePicker picker = ImagePicker();

  bool canPickImage() => imageBytesList.length < maxImages;

  /// Picks an image from the gallery and adds it to the image list.
  ///
  /// Returns an error message if validation fails, null otherwise.
  Future<String?> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) {
      return null;
    }

    // Validate file extension
    final extension = pickedImage.name.split('.').last.toLowerCase();
    if (!supportedImageExtensions.contains(extension)) {
      return 'Unsupported file type ".$extension"\n\n'
          'Please select an image with one of these formats:\n'
          '${supportedImageExtensions.map((e) => '.$e').join(', ')}';
    }

    final bytes = await pickedImage.readAsBytes();
    imageBytesList.add(bytes);
    imageNames.add(pickedImage.name);

    return null;
  }

  /// Removes an image from the list at the specified index.
  void removeImage(int index) {
    imageBytesList.removeAt(index);
    imageNames.removeAt(index);
  }

  /// Loads images from URLs and converts them to bytes for preview.
  ///
  /// Used when editing existing listings to display current images.
  Future<void> loadImagesFromUrls(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    try {
      for (int i = 0; i < imageUrls.length; i++) {
        final imageUrl = imageUrls[i];

        try {
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            imageBytesList.add(response.bodyBytes);

            // Extract filename from URL or generate a default one
            final uri = Uri.parse(imageUrl);
            final pathSegments = uri.pathSegments;
            final filename = pathSegments.isNotEmpty
                ? pathSegments.last
                : 'listing_image_${i + 1}.jpg';

            imageNames.add(filename);
          }
        } catch (e) {
          // Skip individual image if it fails to load
          if (kDebugMode) {
            print('Failed to load image $i: $e');
          }
        }
      }
    } catch (e) {
      // Silently handle errors - image preview is not critical
      if (kDebugMode) {
        print('Error loading images from URLs: $e');
      }
    }
  }

  /// Builds multipart files from the selected image bytes.
  ///
  /// Used when submitting forms to convert image bytes to the format
  /// expected by the API.
  Future<List<http.MultipartFile>> buildMultipartFiles() {
    return Future.wait(
      List.generate(imageBytesList.length, (index) {
        final imageBytes = imageBytesList[index];
        final imageName = imageNames[index];
        return Future.value(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: imageName,
            contentType: _getMediaType(imageName),
          ),
        );
      }),
    );
  }

  /// Determines the MIME type from the image filename.
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

  /// Clears all selected/loaded images.
  void clearImages() {
    imageBytesList.clear();
    imageNames.clear();
  }
}
