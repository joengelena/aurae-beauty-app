import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class VehicleInfoOptionalFields extends StatefulWidget {
  const VehicleInfoOptionalFields({super.key});

  @override
  State<VehicleInfoOptionalFields> createState() =>
      _VehicleInfoOptionalFieldsState();
}

class _VehicleInfoOptionalFieldsState extends State<VehicleInfoOptionalFields> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();
    final orcIncluded = provider.postListingData['orcIncluded'];
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
                  provider.postListingData['orcIncluded'] =
                      value == true ? 1 : 0;
                });
              },
              title: const Text('ORC Included'),
            ),

            DateFormField<PostListingProvider>(
              labelText: 'Rego Expiry Date',
              fieldName: 'regoExpiryDate',
            ),
            DateFormField<PostListingProvider>(
              labelText: 'WOF Expiry Date',
              fieldName: 'wofExpiryDate',
            ),
            StringFormField<PostListingProvider>(
              labelText: 'Number Plate',
              fieldName: 'numberPlate',
            ),
            NumberFormField<PostListingProvider>(
              labelText: 'Seats',
              fieldName: 'seats',
              min: 1,
              max: 100,
            ),
            NumberFormField<PostListingProvider>(
              labelText: 'Doors',
              fieldName: 'doors',
              min: 1,
              max: 20,
            ),
            const StringFormField<PostListingProvider>(labelText: 'Color', fieldName: 'color'),
            NumberFormField<PostListingProvider>(
              labelText: 'Engine Size (cc)',
              fieldName: 'engineSize',
              min: 0,
              max: 20000,
            ),
            DropdownFormField<PostListingProvider>(
              labelText: 'Transmission',
              fieldName: 'transmission',
              options: provider.getAttributeValues('transmission'),
            ),
            DropdownFormField<PostListingProvider>(
              labelText: 'Cylinders',
              fieldName: 'cylinders',
              options: provider.getAttributeValues('cylinders'),
            ),
          ],
        ),
      ],
    );
  }
}
