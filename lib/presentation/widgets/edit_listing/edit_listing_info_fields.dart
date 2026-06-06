import 'package:flutter/material.dart';
import 'package:shine_app/logic/edit_listing_provider.dart';
import 'package:flutter/services.dart';
import 'package:shine_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/number_form_field.dart';
import 'package:shine_app/presentation/widgets/form_fields/string_form_field.dart';
import 'package:provider/provider.dart';

class EditListingInfoFields extends StatefulWidget {
  const EditListingInfoFields({super.key});

  @override
  State<EditListingInfoFields> createState() => _EditListingInfoFieldsState();
}

class _EditListingInfoFieldsState extends State<EditListingInfoFields> {
  late final TextEditingController _discountedPriceController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<EditListingProvider>();
    final initialDiscountedValue =
        provider.formData['discountedPrice']?.toString() ?? '';
    _discountedPriceController = TextEditingController(
      text: initialDiscountedValue,
    );
  }

  @override
  void dispose() {
    _discountedPriceController.dispose();
    super.dispose();
  }

  void _clearDiscountedPrice() {
    final provider = context.read<EditListingProvider>();
    _discountedPriceController.clear();
    provider.formData.remove('discountedPrice');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditListingProvider>();
    final hasDiscountedValue = _discountedPriceController.text.isNotEmpty;

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
          isReadOnly: false,
        ),
        TextFormField(
          controller: _discountedPriceController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Discounted Price (optional)',
            border: const OutlineInputBorder(),
            suffixIcon:
                hasDiscountedValue
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearDiscountedPrice,
                    )
                    : null,
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

            final currentOriginalPrice =
                provider.formData['originalPrice'] as int;
            if (discountedPrice >= currentOriginalPrice) {
              return 'Discounted price must be less than original price (\$$currentOriginalPrice)';
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
            setState(() {});
          },
        ),
        DropdownFormField<EditListingProvider>(
          labelText: 'Condition',
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
