import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/presentation/widgets/garage/compliance_card.dart';
import 'package:motorix_app/utils/constants.dart';
import 'package:provider/provider.dart';

class VehicleCard extends StatelessWidget {
  final UserVehicle vehicle;
  final Widget actionButton;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Push current route onto stack for back button
        final currentRoute = GoRouterState.of(context).uri.path;
        context.read<BackButtonProvider>().pushRoute(currentRoute);

        context.go('/garage/${vehicle.id}');
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: AppConstants.cardShadowElevation,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vehicle.vehiclePhotoUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: AppConstants.listingImageAspectRatio,
                    child: Image.network(
                      vehicle.vehiclePhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child:
                              vehicle.nickname != null
                                  ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        vehicle.nickname!,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                        ),
                        actionButton,
                      ],
                    ),
                    if (vehicle.licensePlate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle.licensePlate!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: ComplianceCard(
                      title: 'REGO expires on',
                      dateString: vehicle.regoExpiryDate,
                    ),
                  ),
                  Expanded(
                    child: ComplianceCard(
                      title: 'WOF expires on',
                      dateString: vehicle.wofExpiryDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ComplianceCard(
                title: 'INSURANCE expires on',
                dateString: vehicle.insuranceExpiryDate,
                description: 'Provider: ${vehicle.insuranceProvider}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
