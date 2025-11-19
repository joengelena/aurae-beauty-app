import 'package:flutter/material.dart';
import 'package:motorix_app/logic/edit_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class EditVehicleInfoOptionalFields extends StatefulWidget {
  const EditVehicleInfoOptionalFields({super.key});

  @override
  State<EditVehicleInfoOptionalFields> createState() =>
      _EditVehicleInfoOptionalFieldsState();
}

class _EditVehicleInfoOptionalFieldsState
    extends State<EditVehicleInfoOptionalFields> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditListingProvider>();
    final orcIncluded = provider.editListingData['orcIncluded'];
    final isOrcChecked = orcIncluded == 1 || orcIncluded == true;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Specifications & Features',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        Column(
          spacing: 12,
          children: [
            CheckboxListTile(
              value: isOrcChecked,
              onChanged: (value) {
                setState(() {
                  provider.editListingData['orcIncluded'] =
                      value == true ? 1 : 0;
                });
              },
              title: const Text('ORC Included'),
            ),
            DateFormField(
              labelText: 'Rego Expiry Date',
              fieldName: 'regoExpiryDate',
            ),
            DateFormField(
              labelText: 'WOF Expiry Date',
              fieldName: 'wofExpiryDate',
            ),
            StringFormField(
              labelText: 'Number Plate',
              fieldName: 'numberPlate',
            ),
            NumberFormField(
              labelText: 'Seats',
              fieldName: 'seats',
              min: 1,
              max: 100,
            ),
            NumberFormField(
              labelText: 'Doors',
              fieldName: 'doors',
              min: 1,
              max: 20,
            ),
            NumberFormField(
              labelText: 'Previous Owners',
              fieldName: 'previousOwners',
              min: 0,
              max: 50,
            ),
            const StringFormField(labelText: 'Color', fieldName: 'color'),
            NumberFormField(
              labelText: 'Engine Size (cc)',
              fieldName: 'engineSize',
              min: 0,
              max: 20000,
            ),
            DropdownFormField(
              labelText: 'Transmission',
              fieldName: 'transmission',
              attributeName: 'transmission',
            ),
            DropdownFormField(
              labelText: 'Cylinders',
              fieldName: 'cylinders',
              attributeName: 'cylinders',
            ),
          ],
        ),
      ],
    );
  }
}
