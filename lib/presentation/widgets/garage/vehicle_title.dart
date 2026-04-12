import 'package:flutter/material.dart';
import 'package:shine_app/data/models/user_vehicle.dart';
import 'package:shine_app/utils/utils.dart';

class VehicleTitle extends StatelessWidget {
  final UserVehicle vehicle;

  const VehicleTitle({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final fullName = formatVehicleName(vehicle);

    if (vehicle.nickname != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            vehicle.nickname!,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fullName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      fullName,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
