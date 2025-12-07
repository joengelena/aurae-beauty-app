import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/logic/form_data_provider.dart';

/// Interface for providers that manage listing form data.
///
/// This interface enables form field widgets to work with both
/// post and edit listing providers without coupling to specific implementations.
///
/// Implementations:
/// - [PostListingProvider] - For creating new listings
/// - [EditListingProvider] - For updating existing listings
abstract class ListingFormDataProvider extends ChangeNotifier
    implements FormDataProvider {
  /// Available listing attributes for dropdown fields.
  ///
  /// Contains options like vehicle makes, body types, fuel types, etc.
  /// Loaded asynchronously from the API.
  List<ListingAttribute> get listingAttributeOptions;

  /// List of image bytes for selected/loaded images
  List<Uint8List> get imageBytesList;

  /// List of image filenames
  List<String> get imageNames;

  /// Check if more images can be picked (max 10)
  bool canPickImage();

  /// Pick an image from gallery
  /// Returns error message if validation fails, null otherwise
  Future<String?> pickImage();

  /// Remove an image at the given index
  void removeImage(int index);
}
