import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_empty_state.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_error_state.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_list.dart';
import 'package:motorix_app/utils/feedback_helpers.dart';
import 'package:provider/provider.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {

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
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _handleAddVehicle,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(GarageProvider garageProvider) {
    if (garageProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (garageProvider.hasError) {
      return GarageErrorState(
        errorMessage: garageProvider.errorMessage,
        onRetry: garageProvider.fetchVehicles,
      );
    }

    if (garageProvider.vehicles.isEmpty) {
      return const GarageEmptyState();
    }

    return VehicleList(
      vehicles: garageProvider.vehicles,
      onRefresh: garageProvider.fetchVehicles,
      onEditVehicle: _handleEditVehicle,
      onDeleteVehicle: _handleDeleteVehicle,
    );
  }

  Future<void> _handleAddVehicle() async {
    final wasAdded = await context.push<bool>('/garage/add');

    if (wasAdded == true && mounted) {
      context.read<GarageProvider>().fetchVehicles();
    }
  }

  Future<void> _handleEditVehicle(UserVehicle vehicle) async {
    final wasUpdated = await context.push<bool>('/garage/${vehicle.id}/edit');

    if (wasUpdated == true && mounted) {
      context.read<GarageProvider>().fetchVehicles();
    }
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
        FeedbackHelpers.showSuccessSnackBar(context, 'Vehicle deleted successfully');
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
