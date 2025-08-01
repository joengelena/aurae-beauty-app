import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/post_listing/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/post_listing/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/post_listing/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/post_listing/string_form_field.dart';
import 'package:provider/provider.dart';

class VehicleInfoOptionalFields extends StatelessWidget {
  const VehicleInfoOptionalFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Specifications & Features',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        Column(
          spacing: 12,
          children: [
            CheckboxListTile(
              value: false,
              onChanged:
                  (value) =>
                      provider.postListingData['orcIncluded'] = value ?? false,
              title: Text('ORC Included'),
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
            StringFormField(labelText: 'Color', fieldName: 'color'),
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
