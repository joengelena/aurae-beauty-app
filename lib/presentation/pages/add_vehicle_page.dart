import 'package:flutter/material.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/add_vehicle_form.dart';
import 'package:provider/provider.dart';

class AddVehiclePage extends StatelessWidget {
  const AddVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddVehicleProvider(),
      child: const Scaffold(
        body: AddVehicleForm(),
      ),
    );
  }
}
