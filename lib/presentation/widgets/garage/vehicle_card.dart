import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/presentation/widgets/garage/update_expiry_date_dialog.dart';
import 'package:motorix_app/utils/constants.dart';

class VehicleCard extends StatelessWidget {
  final UserVehicle vehicle;
  final Widget? topRightButton;

  const VehicleCard({super.key, required this.vehicle, this.topRightButton});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/garage/${vehicle.id}'),
      child: Card(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (vehicle.licensePlate != null) ...[
                          const SizedBox(height: 4),
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => _showUpdateExpiryDialog(
                                  context,
                                  title: 'Update Registration',
                                  currentDate: vehicle.regoExpiryDate,
                                  fieldName: 'regoExpiryDate',
                                  successMessage:
                                      'Registration expiry updated successfully',
                                ),
                            child: const Text('Update REGO'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => _showUpdateExpiryDialog(
                                  context,
                                  title: 'Update WOF',
                                  currentDate: vehicle.wofExpiryDate,
                                  fieldName: 'wofExpiryDate',
                                  successMessage:
                                      'WOF expiry updated successfully',
                                ),
                            child: const Text('Update WOF'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _handleAddService(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Service Record'),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (topRightButton != null)
              Positioned(top: 4, right: 4, child: topRightButton!),
          ],
        ),
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

  void _showUpdateExpiryDialog(
    BuildContext context, {
    required String title,
    required String currentDate,
    required String fieldName,
    required String successMessage,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => UpdateExpiryDateDialog(
            title: title,
            currentDate: currentDate,
            fieldName: fieldName,
            vehicleId: vehicle.id,
            successMessage: successMessage,
          ),
    );
  }

  void _handleAddService(BuildContext context) {
    context.go('/garage/${vehicle.id}/add-service');
  }
}
