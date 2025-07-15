import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostListingProvider extends ChangeNotifier {
  PostListingProvider();

  final List<Uint8List> imageBytesList = [];

  // Required fields
  final locationController = TextEditingController();
  final conditionController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final kilometersController = TextEditingController();
  final fuelTypeController = TextEditingController();
  final bodyTypeController = TextEditingController();
  final driveTypeController = TextEditingController();
  final listingEndDateController = TextEditingController();

  // Optional fields
  final regoExpiryDateController = TextEditingController();
  final wofExpiryDateController = TextEditingController();
  final numberPlateController = TextEditingController();
  final seatsController = TextEditingController();
  final doorsController = TextEditingController();
  final colorController = TextEditingController();
  final engineSizeController = TextEditingController();
  final transmissionController = TextEditingController();
  final cylindersController = TextEditingController();
  bool orcIncluded = false;

  final picker = ImagePicker();

  bool canPickImage() => imageBytesList.length < 10;

  Future<void> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      imageBytesList.add(bytes);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    locationController.dispose();
    conditionController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    makeController.dispose();
    modelController.dispose();
    yearController.dispose();
    kilometersController.dispose();
    fuelTypeController.dispose();
    bodyTypeController.dispose();
    driveTypeController.dispose();
    numberPlateController.dispose();
    seatsController.dispose();
    doorsController.dispose();
    colorController.dispose();
    engineSizeController.dispose();
    transmissionController.dispose();
    cylindersController.dispose();
  }
}
