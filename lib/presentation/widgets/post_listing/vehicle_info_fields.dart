import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/post_listing/number_form_field.dart';

class VehicleInfoFields extends StatelessWidget {
  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController kilometersController;
  final TextEditingController fuelTypeController;
  final TextEditingController bodyTypeController;
  final TextEditingController driveTypeController;

  const VehicleInfoFields({
    super.key,
    required this.makeController,
    required this.modelController,
    required this.yearController,
    required this.kilometersController,
    required this.fuelTypeController,
    required this.bodyTypeController,
    required this.driveTypeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Vehicle Info', style: Theme.of(context).textTheme.headlineMedium),
        TextFormField(
          controller: makeController,
          decoration: InputDecoration(labelText: 'Make'),
        ),
        TextFormField(
          controller: modelController,
          decoration: InputDecoration(labelText: 'Model'),
        ),
        NumberFormField(fieldController: yearController, labelText: 'Year'),
        NumberFormField(
          fieldController: kilometersController,
          labelText: 'Kilometers',
        ),
        TextFormField(
          controller: fuelTypeController,
          decoration: InputDecoration(labelText: 'Fuel Type'),
        ),
        TextFormField(
          controller: bodyTypeController,
          decoration: InputDecoration(labelText: 'Body Type'),
        ),
        TextFormField(
          controller: driveTypeController,
          decoration: InputDecoration(labelText: 'Drive Type'),
        ),
      ],
    );
  }
}
