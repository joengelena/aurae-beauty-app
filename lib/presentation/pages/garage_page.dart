import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_empty_state.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_error_state.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_list.dart';
import 'package:provider/provider.dart';

class GaragePage extends StatelessWidget {
  const GaragePage({super.key});

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
            onPressed: () => context.go('/garage/add'),
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
    );
  }
}
