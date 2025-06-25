import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/post_listing/date_form_field.dart';

class ListingInfoFields extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController conditionController;
  final TextEditingController priceController;
  final TextEditingController listingEndDateController;
  final TextEditingController descriptionController;

  const ListingInfoFields({
    super.key,
    required this.locationController,
    required this.conditionController,
    required this.priceController,
    required this.listingEndDateController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Listing Info', style: Theme.of(context).textTheme.headlineMedium),
        TextFormField(
          controller: locationController,
          decoration: InputDecoration(labelText: 'Location'),
        ),
        TextFormField(
          controller: conditionController,
          decoration: InputDecoration(labelText: 'Vehicle Condition'),
        ),
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Price'),
        ),
        DateFormField(
          dateController: listingEndDateController,
          labelText: 'Listing End Date',
        ),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: 'Description'),
          maxLines: 4,
        ),
      ],
    );
  }
}
