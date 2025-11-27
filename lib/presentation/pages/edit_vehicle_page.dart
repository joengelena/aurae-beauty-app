import 'package:flutter/material.dart';

class EditVehiclePage extends StatelessWidget {
  final String vehicleId;

  const EditVehiclePage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Edit Vehicle Page - ID: $vehicleId',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
