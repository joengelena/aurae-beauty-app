import 'package:flutter/material.dart';
import 'package:motorix_app/logic/edit_vehicle_provider.dart';
import 'package:motorix_app/logic/vehicle_form_provider.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/vehicle_form.dart';
import 'package:provider/provider.dart';

class EditVehiclePage extends StatelessWidget {
  final String vehicleId;

  const EditVehiclePage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VehicleFormProvider>(
      create: (_) => EditVehicleProvider(int.parse(vehicleId)),
      child: const Scaffold(
        body: VehicleForm(mode: VehicleFormMode.edit),
      ),
    );
  }
}
