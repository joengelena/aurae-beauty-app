import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/post_listing/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/post_listing/number_form_field.dart';

class VehicleInfoOptionalFields extends StatelessWidget {
  final bool orcIncluded;
  final Function(bool) updateOrcIncluded;
  final TextEditingController regoExpiryDateController;
  final TextEditingController wofExpiryDateController;
  final TextEditingController numberPlateController;
  final TextEditingController seatsController;
  final TextEditingController doorsController;
  final TextEditingController colorController;
  final TextEditingController engineSizeController;
  final TextEditingController transmissionController;
  final TextEditingController cylindersController;

  const VehicleInfoOptionalFields({
    super.key,
    required this.orcIncluded,
    required this.updateOrcIncluded,
    required this.regoExpiryDateController,
    required this.wofExpiryDateController,
    required this.numberPlateController,
    required this.seatsController,
    required this.doorsController,
    required this.colorController,
    required this.engineSizeController,
    required this.transmissionController,
    required this.cylindersController,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Extra fields',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      children: [
        CheckboxListTile(
          value: orcIncluded,
          onChanged: (value) => updateOrcIncluded(value ?? false),
          title: Text('ORC Included'),
        ),
        DateFormField(
          dateController: regoExpiryDateController,
          labelText: 'Rego Expiry Date',
          firstDate: DateTime(2020),
        ),
        DateFormField(
          dateController: wofExpiryDateController,
          labelText: 'WOF Expiry Date',
          firstDate: DateTime(2020),
        ),
        TextFormField(
          controller: numberPlateController,
          decoration: InputDecoration(labelText: 'Number Plate'),
        ),
        NumberFormField(fieldController: seatsController, labelText: 'Seats'),
        NumberFormField(fieldController: doorsController, labelText: 'Doors'),
        TextFormField(
          controller: colorController,
          decoration: InputDecoration(labelText: 'Color'),
        ),
        NumberFormField(
          fieldController: engineSizeController,
          labelText: 'Engine Size (cc)',
        ),
        TextFormField(
          controller: transmissionController,
          decoration: InputDecoration(labelText: 'Transmission'),
        ),
        TextFormField(
          controller: cylindersController,
          decoration: InputDecoration(labelText: 'Cylinders'),
        ),
      ],
    );
  }
}
