import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/presentation/widgets/common/action_menu_button.dart';
import 'package:motorix_app/utils/feedback_helpers.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:provider/provider.dart';

class VehicleActionMenu extends StatelessWidget {
  final UserVehicle vehicle;
  final bool redirectAfterDelete;

  const VehicleActionMenu({
    super.key,
    required this.vehicle,
    this.redirectAfterDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionMenuButton(
      options: [
        MenuOption(
          icon: Icons.edit,
          title: 'Edit',
          onTap: () => _handleEditVehicle(context),
        ),
        MenuOption(
          icon: Icons.delete,
          title: 'Delete',
          iconColor: themeRed,
          titleColor: themeRed,
          onTap: () => _handleDeleteVehicle(context),
        ),
      ],
    );
  }

  void _handleEditVehicle(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);
    context.go('/garage/${vehicle.id}/edit');
  }

  Future<void> _handleDeleteVehicle(BuildContext context) async {
    final vehicleName = formatVehicleName(vehicle);
    final confirmed = await FeedbackHelpers.showDeleteConfirmation(
      context,
      title: 'Delete Vehicle',
      message:
          'Are you sure you want to delete $vehicleName? This action cannot be undone.',
    );

    if (!confirmed || !context.mounted) return;

    final garageProvider = context.read<GarageProvider>();

    try {
      await garageProvider.deleteVehicle(vehicle.id);

      if (context.mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          context,
          'Vehicle deleted successfully',
        );

        if (redirectAfterDelete) {
          context.go('/garage');
        }
      }
    } catch (e) {
      if (context.mounted) {
        FeedbackHelpers.showErrorSnackBar(
          context,
          'Failed to delete vehicle: ${e.toString()}',
        );
      }
    }
  }
}
