import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/presentation/widgets/common/action_menu_button.dart';
import 'package:motorix_app/presentation/widgets/common/labeled_fab.dart';
import 'package:motorix_app/presentation/widgets/garage/listings_carousel_widget.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_card.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_empty_state.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_error_state.dart';
import 'package:motorix_app/utils/feedback_helpers.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:provider/provider.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GarageProvider>().fetchVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(message: 'Sign in to access your garage.');
    }

    final garageProvider = context.watch<GarageProvider>();

    return Stack(
      children: [
        _buildBody(garageProvider),
        LabeledFab(label: 'Add', onPressed: _handleAddVehicle),
      ],
    );
  }

  Widget _buildBody(GarageProvider garageProvider) {
    if (garageProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (garageProvider.hasError) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: GarageErrorState(
            errorMessage: garageProvider.errorMessage,
            onRetry: garageProvider.fetchVehicles,
          ),
        ),
      );
    }

    if (garageProvider.vehicles.isEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ListingsCarouselWidget(),
                const GarageEmptyState(),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: garageProvider.fetchVehicles,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
            itemCount:
                garageProvider.vehicles.length +
                2, // +1 for carousel and +1 for title
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: ListingsCarouselWidget(),
                );
              }

              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'My Vehicles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              final vehicleIndex = index - 2;
              final vehicle = garageProvider.vehicles[vehicleIndex];

              return VehicleCard(
                vehicle: vehicle,
                actionButton: ActionMenuButton(
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
        onTap: () => _handleEditVehicle(vehicle),
      ),
      MenuOption(
        icon: Icons.delete,
        title: 'Delete',
        iconColor: themeRed,
        titleColor: themeRed,
        onTap: () => _handleDeleteVehicle(vehicle),
      ),
    ];
  }

  void _handleAddVehicle() {
    // Push current route onto stack for back button
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);

    context.go('/garage/add');
  }

  void _handleEditVehicle(UserVehicle vehicle) {
    // Push current route onto stack for back button
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);

    context.go('/garage/${vehicle.id}/edit');
  }

  Future<void> _handleDeleteVehicle(UserVehicle vehicle) async {
    final vehicleName = '${vehicle.year} ${vehicle.make} ${vehicle.model}';
    final confirmed = await FeedbackHelpers.showDeleteConfirmation(
      context,
      title: 'Delete Vehicle',
      message:
          'Are you sure you want to delete $vehicleName? This action cannot be undone.',
    );

    if (!confirmed || !mounted) return;

    final garageProvider = context.read<GarageProvider>();

    try {
      await garageProvider.deleteVehicle(vehicle.id);

      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          context,
          'Vehicle deleted successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        FeedbackHelpers.showErrorSnackBar(
          context,
          'Failed to delete vehicle: ${e.toString()}',
        );
      }
    }
  }
}
