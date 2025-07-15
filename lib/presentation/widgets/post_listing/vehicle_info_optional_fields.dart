import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/post_listing/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/post_listing/number_form_field.dart';
import 'package:provider/provider.dart';

class VehicleInfoOptionalFields extends StatelessWidget {
  const VehicleInfoOptionalFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Extra fields',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      children: [
        CheckboxListTile(
          value: provider.orcIncluded,
          onChanged: (value) => provider.orcIncluded = value ?? false,
          title: Text('ORC Included'),
        ),
        DateFormField(
          dateController: provider.regoExpiryDateController,
          labelText: 'Rego Expiry Date',
          firstDate: DateTime(2020),
        ),
        DateFormField(
          dateController: provider.wofExpiryDateController,
          labelText: 'WOF Expiry Date',
          firstDate: DateTime(2020),
        ),
        TextFormField(
          controller: provider.numberPlateController,
          decoration: InputDecoration(labelText: 'Number Plate'),
        ),
        NumberFormField(
          fieldController: provider.seatsController,
          labelText: 'Seats',
        ),
        NumberFormField(
          fieldController: provider.doorsController,
          labelText: 'Doors',
        ),
        TextFormField(
          controller: provider.colorController,
          decoration: InputDecoration(labelText: 'Color'),
        ),
        NumberFormField(
          fieldController: provider.engineSizeController,
          labelText: 'Engine Size (cc)',
        ),
        TextFormField(
          controller: provider.transmissionController,
          decoration: InputDecoration(labelText: 'Transmission'),
        ),
        TextFormField(
          controller: provider.cylindersController,
          decoration: InputDecoration(labelText: 'Cylinders'),
        ),
      ],
    );
  }
}
