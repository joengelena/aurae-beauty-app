import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_card.dart';

class VehicleList extends StatelessWidget {
  final List<UserVehicle> vehicles;
  final Future<void> Function() onRefresh;

  const VehicleList({
    super.key,
    required this.vehicles,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              return VehicleCard(vehicle: vehicles[index]);
            },
          ),
        ),
      ),
    );
  }
}
