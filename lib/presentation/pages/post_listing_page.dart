import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/post_listing/listing_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/select_multiple_images.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_optional_fields.dart';

class PostListingPage extends StatefulWidget {
  const PostListingPage({super.key});

  @override
  State<PostListingPage> createState() => _PostListingPageState();
}

class _PostListingPageState extends State<PostListingPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Uint8List> imageBytesList = [];
  DateTime? uploadDate;

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

  void updateOrcIncluded(bool value) {
    setState(() {
      orcIncluded = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 32,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                VehicleInfoFields(
                  makeController: makeController,
                  modelController: modelController,
                  yearController: yearController,
                  kilometersController: kilometersController,
                  fuelTypeController: fuelTypeController,
                  bodyTypeController: bodyTypeController,
                  driveTypeController: driveTypeController,
                ),
                VehicleInfoOptionalFields(
                  orcIncluded: orcIncluded,
                  updateOrcIncluded: updateOrcIncluded,
                  regoExpiryDateController: regoExpiryDateController,
                  wofExpiryDateController: wofExpiryDateController,
                  numberPlateController: numberPlateController,
                  seatsController: seatsController,
                  doorsController: doorsController,
                  colorController: colorController,
                  engineSizeController: engineSizeController,
                  transmissionController: transmissionController,
                  cylindersController: cylindersController,
                ),
                ListingInfoFields(
                  locationController: locationController,
                  conditionController: conditionController,
                  priceController: priceController,
                  listingEndDateController: listingEndDateController,
                  descriptionController: descriptionController,
                ),
                SelectMultipleImages(imageBytesList: imageBytesList),
                SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle submission logic here
                    }
                  },
                  child: Text('Submit listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    super.dispose();
  }
}
