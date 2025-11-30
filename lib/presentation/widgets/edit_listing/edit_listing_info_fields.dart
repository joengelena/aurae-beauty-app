import 'package:flutter/material.dart';
import 'package:motorix_app/logic/edit_listing_provider.dart';
import 'package:flutter/services.dart';
import 'package:motorix_app/logic/edit_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';

class EditListingInfoFields extends StatelessWidget {
  const EditListingInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditListingProvider>();
    final originalPrice = provider.formData['originalPrice'] as int;
    final initialDiscountedValue = provider.formData['discountedPrice']?.toString() ?? '';

    return Column(
      spacing: 12,
      children: [
        Text(
          'Listing Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        NumberFormField<EditListingProvider>(
          labelText: 'Original Price',
          fieldName: 'originalPrice',
          min: 0,
          max: 100000000,
          isRequired: true,
          isReadOnly: true,
        ),
                TextFormField(
          initialValue: initialDiscountedValue,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Discounted Price (optional)',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // Optional field
            }

            final discountedPrice = int.tryParse(value);

            if (discountedPrice == null) {
              return 'Must be a number';
            }

            if (discountedPrice < 0 || discountedPrice > 100000000) {
              return 'Must be between 0 and 100000000';
            }

            if (discountedPrice >= originalPrice) {
              return 'Discounted price must be less than original price (\$$originalPrice)';
            }

            return null;
          },
          onChanged: (val) {
            if (val.isEmpty) {
              provider.formData.remove('discountedPrice');
            } else {
              final intValue = int.tryParse(val);
              if (intValue != null) {
                provider.formData['discountedPrice'] = intValue;
              }
            }
          },
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Vehicle Condition',
          fieldName: 'vehicleCondition',
          options: provider.getAttributeValues('vehicle_condition'),
          isRequired: true,
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Location',
          fieldName: 'location',
          options: provider.getAttributeValues('location'),
          isRequired: true,
        ),
        DateFormField<EditListingProvider>(
          labelText: 'Listing End Date',
          fieldName: 'endDate',
          isRequired: true,
        ),
        StringFormField<EditListingProvider>(
          labelText: 'Description',
          fieldName: 'description',
          isRequired: true,
          maxLines: 5,
          alignLabelWithHint: true,
        ),
      ],
    );
  }
}
