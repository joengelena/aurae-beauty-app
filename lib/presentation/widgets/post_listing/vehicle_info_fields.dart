import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/post_listing/number_form_field.dart';
import 'package:provider/provider.dart';

class VehicleInfoFields extends StatelessWidget {
  const VehicleInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return Column(
      children: [
        Text('Vehicle Info', style: Theme.of(context).textTheme.headlineMedium),
        TextFormField(
          controller: provider.makeController,
          decoration: InputDecoration(labelText: 'Make'),
        ),
        TextFormField(
          controller: provider.modelController,
          decoration: InputDecoration(labelText: 'Model'),
        ),
        NumberFormField(
          fieldController: provider.yearController,
          labelText: 'Year',
        ),
        NumberFormField(
          fieldController: provider.kilometersController,
          labelText: 'Kilometers',
        ),
        TextFormField(
          controller: provider.fuelTypeController,
          decoration: InputDecoration(labelText: 'Fuel Type'),
        ),
        TextFormField(
          controller: provider.bodyTypeController,
          decoration: InputDecoration(labelText: 'Body Type'),
        ),
        TextFormField(
          controller: provider.driveTypeController,
          decoration: InputDecoration(labelText: 'Drive Type'),
        ),
      ],
    );
  }
}
