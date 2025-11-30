import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/utils/constants.dart';

class VehicleCard extends StatelessWidget {
  final UserVehicle vehicle;
  final Widget? topRightButton;

  const VehicleCard({super.key, required this.vehicle, this.topRightButton});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: AppConstants.cardShadowElevation,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vehicle.licensePlate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          vehicle.licensePlate!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (vehicle.vehiclePhotoUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 200,
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
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem(
                            context,
                            'Registration Ends',
                            _formatDate(vehicle.regoExpiryDate),
                            _isExpiringSoon(vehicle.regoExpiryDate),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context,
                            'WOF Ends',
                            _formatDate(vehicle.wofExpiryDate),
                            _isExpiringSoon(vehicle.wofExpiryDate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (topRightButton != null)
            Positioned(top: 4, right: 4, child: topRightButton!),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    bool isWarning,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: isWarning ? Colors.orange.shade700 : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  bool _isExpiringSoon(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      return difference <= 30 && difference >= 0;
    } catch (e) {
      return false;
    }
  }
}
