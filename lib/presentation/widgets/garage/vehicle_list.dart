import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/presentation/widgets/common/action_menu_button.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_card.dart';

class VehicleList extends StatelessWidget {
  final List<UserVehicle> vehicles;
  final Future<void> Function() onRefresh;
  final void Function(UserVehicle) onEditVehicle;
  final void Function(UserVehicle) onDeleteVehicle;

  const VehicleList({
    super.key,
    required this.vehicles,
    required this.onRefresh,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
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
              final vehicle = vehicles[index];

              return VehicleCard(
                vehicle: vehicle,
                topRightButton: ActionMenuButton(
                  options: _buildMenuOptions(vehicle),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<MenuOption> _buildMenuOptions(UserVehicle vehicle) {
    return [
      MenuOption(
        icon: Icons.edit,
        title: 'Edit',
        onTap: () => onEditVehicle(vehicle),
      ),
      MenuOption(
        icon: Icons.delete,
        title: 'Delete',
        iconColor: Colors.red,
        titleColor: Colors.red,
        onTap: () => onDeleteVehicle(vehicle),
      ),
    ];
  }
}
