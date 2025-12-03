import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_service_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/logic/service_form_provider.dart';
import 'package:motorix_app/presentation/widgets/service_form/service_form.dart';
import 'package:provider/provider.dart';

class AddServicePage extends StatelessWidget {
  final int vehicleId;

  const AddServicePage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final garageProvider = context.read<GarageProvider>();
    final vehicle = garageProvider.vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => throw Exception('Vehicle not found'),
    );

    return ChangeNotifierProvider<ServiceFormProvider>(
      create: (_) => AddServiceProvider(vehicle: vehicle),
      child: const Scaffold(
        body: ServiceForm(mode: ServiceFormMode.add),
      ),
    );
  }
}
