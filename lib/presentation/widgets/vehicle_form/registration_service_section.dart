import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:motorix_app/presentation/widgets/form_fields/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/string_form_field.dart';

class RegistrationServiceSection extends StatelessWidget {
  const RegistrationServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));

    return Column(
      spacing: 12,
      children: [
        Text(
          'Registration & Service',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const StringFormField<AddVehicleProvider>(
          labelText: 'License Plate',
          fieldName: 'licensePlate',
        ),
        DateFormField<AddVehicleProvider>(
          labelText: 'Registration Expiry',
          fieldName: 'regoExpiryDate',
          firstDate: oneYearAgo,
        ),
        DateFormField<AddVehicleProvider>(
          labelText: 'WOF Expiry',
          fieldName: 'wofExpiryDate',
          firstDate: oneYearAgo,
        ),
      ],
    );
  }
}
