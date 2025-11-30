import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/listing_attribute.dart';
import 'package:motorix_app/logic/form_data_provider.dart';

/// Interface for providers that manage vehicle form data.
///
/// This interface enables the vehicle form widget to work with both
/// add and edit vehicle providers without coupling to specific implementations.
///
/// Implementations:
/// - [AddVehicleProvider] - For adding new vehicles to garage
/// - [EditVehicleProvider] - For editing existing vehicles in garage
abstract class VehicleFormProvider extends ChangeNotifier implements FormDataProvider {

  /// Available listing attributes for dropdown fields.
  ///
  /// Contains options like vehicle makes, fuel types, transmission, etc.
  /// Loaded asynchronously from the API.
  List<ListingAttribute> get listingAttributeOptions;

  /// Vehicle image data (bytes).
  Uint8List? get vehicleImageBytes;

  /// MIME type of the vehicle image.
  String? get vehicleImageMimeType;

  /// Loading state during API calls.
  bool get isLoading;

  /// Success state after form submission.
  bool get isSuccess;

  /// Error message to display to user.
  String get errorMessage;

  /// Set the vehicle image.
  void setVehicleImage(Uint8List imageBytes, String mimeType);

  /// Remove the vehicle image.
  void removeVehicleImage();

  /// Submit the form (polymorphic - add or update).
  Future<void> submitForm();

  /// Get the attribute values for a specific attribute name.
  ///
  /// Returns a list of possible values for dropdown fields.
  /// Returns an empty list if the attribute is not found.
  List<String> getAttributeValues(String attributeName);
}
