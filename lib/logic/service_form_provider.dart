import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/form_data_provider.dart';

/// Interface for providers that manage service record form data.
///
/// This interface enables the service form widget to work with both
/// add and edit service providers without coupling to specific implementations.
///
/// Implementations:
/// - [AddServiceProvider] - For adding new service records
/// - Future: EditServiceProvider - For editing existing service records
abstract class ServiceFormProvider extends ChangeNotifier implements FormDataProvider {

  /// The vehicle for which the service record is being added/edited.
  UserVehicle get vehicle;

  /// Loading state during API calls.
  bool get isLoading;

  /// Success state after form submission.
  bool get isSuccess;

  /// Error message to display to user.
  String get errorMessage;

  /// Submit the form (polymorphic - add or update).
  Future<void> submitForm();
}
