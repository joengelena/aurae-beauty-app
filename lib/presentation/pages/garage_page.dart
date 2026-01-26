import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/presentation/widgets/common/labeled_fab.dart';
import 'package:motorix_app/presentation/widgets/garage/listings_carousel_widget.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_action_menu.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_card.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_empty_state.dart';
import 'package:motorix_app/presentation/widgets/garage/garage_error_state.dart';
import 'package:motorix_app/utils/constants.dart';
import 'package:provider/provider.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  static const _horizontalPadding =
      AppConstants.spacingLarge * 2; // 16 left + 16 right

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GarageProvider>().fetchVehicles();
    });
  }

  double _calculateItemWidth(double availableWidth, int crossAxisCount) {
    final totalSpacing = _horizontalPadding +
        (AppConstants.spacingMedium * (crossAxisCount - 1));
    return (availableWidth - totalSpacing) / crossAxisCount;
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
          constraints: const BoxConstraints(
            maxWidth: AppConstants.contentMaxWidth,
          ),
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
          constraints: const BoxConstraints(
            maxWidth: AppConstants.contentMaxWidth,
          ),
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
        constraints: const BoxConstraints(
          maxWidth: AppConstants.contentMaxWidth,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final crossAxisCount =
                availableWidth >= AppConstants.twoColumnBreakpoint ? 2 : 1;
            final itemWidth = _calculateItemWidth(
              availableWidth,
              crossAxisCount,
            );

            return RefreshIndicator(
              onRefresh: garageProvider.fetchVehicles,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingExtraLarge,
                ),
                children: [
                  const ListingsCarouselWidget(),
                  const SizedBox(height: AppConstants.spacingLarge),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.spacingLarge,
                    ),
                    child: Text(
                      'My Vehicles',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Wrap(
                    spacing: AppConstants.spacingMedium,
                    runSpacing: AppConstants.spacingMedium,
                    children: garageProvider.vehicles.map((vehicle) {
                      return SizedBox(
                        width: itemWidth,
                        child: VehicleCard(
                          vehicle: vehicle,
                          actionButton: VehicleActionMenu(vehicle: vehicle),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleAddVehicle() {
    // Push current route onto stack for back button
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);

    context.go('/garage/add');
  }
}
