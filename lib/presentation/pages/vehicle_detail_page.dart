import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/vehicle_detail_provider.dart';
import 'package:motorix_app/presentation/widgets/garage/update_expiry_date_dialog.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class VehicleDetailPage extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailPage({super.key, required this.vehicleId});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleDetailProvider>().getVehicle(
            int.parse(widget.vehicleId),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleDetailProvider>();
    final vehicle = provider.vehicle;

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.hasError || vehicle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Vehicle not found',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return _buildDetailPage(context, vehicle);
  }

  Widget _buildDetailPage(BuildContext context, UserVehicle vehicle) {
    // Key specs for grid display
    final keySpecs = [
      {
        'icon': Icons.speed,
        'label': 'Odometer',
        'value': vehicle.odometerReading != null
            ? '${NumberFormat('#,###').format(vehicle.odometerReading!)} ${vehicle.odometerUnit}'
            : 'Not recorded'
      },
      {
        'icon': Icons.local_gas_station,
        'label': 'Fuel Type',
        'value': vehicle.fuelType ?? 'Not specified'
      },
      {
        'icon': Icons.settings,
        'label': 'Transmission',
        'value': vehicle.transmission ?? 'Not specified'
      },
      {
        'icon': Icons.palette,
        'label': 'Color',
        'value': vehicle.color ?? 'Not specified'
      },
    ];

    // Vehicle details
    final vehicleDetails = {
      'License Plate': vehicle.licensePlate,
      'Color': vehicle.color,
      'Fuel Type': vehicle.fuelType,
      'Transmission': vehicle.transmission,
      'Odometer': vehicle.odometerReading != null
          ? '${NumberFormat('#,###').format(vehicle.odometerReading!)} ${vehicle.odometerUnit}'
          : null,
      'Added': formatDate(vehicle.createdAt),
      'Last Updated': formatDate(vehicle.updatedAt),
    };

    final regoStatus = _getComplianceStatus(vehicle.regoExpiryDate);
    final wofStatus = _getComplianceStatus(vehicle.wofExpiryDate);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            spacing: 16,
            children: [
                // Vehicle Image
                if (vehicle.vehiclePhotoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        vehicle.vehiclePhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.directions_car,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),

                // Title and Edit Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            if (vehicle.licensePlate != null) ...[
                              SizedBox(height: 4),
                              Text(
                                vehicle.licensePlate!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          context.go('/garage/${vehicle.id}/edit');
                        },
                      ),
                    ],
                  ),
                ),

                // Compliance Status Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildComplianceCard(
                          context,
                          'REGO',
                          _formatDateString(vehicle.regoExpiryDate),
                          regoStatus,
                          () => _showUpdateExpiryDialog(
                            context,
                            title: 'Update Registration',
                            currentDate: vehicle.regoExpiryDate,
                            fieldName: 'regoExpiryDate',
                            successMessage:
                                'Registration expiry updated successfully',
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildComplianceCard(
                          context,
                          'WOF',
                          _formatDateString(vehicle.wofExpiryDate),
                          wofStatus,
                          () => _showUpdateExpiryDialog(
                            context,
                            title: 'Update WOF',
                            currentDate: vehicle.wofExpiryDate,
                            fieldName: 'wofExpiryDate',
                            successMessage: 'WOF expiry updated successfully',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Key Specs Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: keySpecs.map((spec) {
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              spec['icon'] as IconData,
                              size: 20,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    spec['label'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    spec['value'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Vehicle Details Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Vehicle Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      spacing: 8,
                      children: [
                        for (var entry in vehicleDetails.entries)
                          if (entry.value != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '${entry.value}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),
                ),

                // Notes Section (if exists)
                if (vehicle.notes != null && vehicle.notes!.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Notes',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vehicle.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],

                // Maintenance Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Maintenance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No service history yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.go('/garage/${vehicle.id}/add-service');
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Service Record'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceCard(
    BuildContext context,
    String title,
    String date,
    ComplianceStatus status,
    VoidCallback onUpdate,
  ) {
    Color cardColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ComplianceStatus.valid:
        cardColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      case ComplianceStatus.expiringSoon:
        cardColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.warning;
        break;
      case ComplianceStatus.expired:
        cardColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: textColor),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onUpdate,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8),
                side: BorderSide(color: textColor),
                foregroundColor: textColor,
              ),
              child: Text(
                'Update',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ComplianceStatus _getComplianceStatus(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference < 0) {
        return ComplianceStatus.expired;
      } else if (difference <= 30) {
        return ComplianceStatus.expiringSoon;
      } else {
        return ComplianceStatus.valid;
      }
    } catch (e) {
      return ComplianceStatus.valid;
    }
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
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
      builder: (context) => UpdateExpiryDateDialog(
        title: title,
        currentDate: currentDate,
        fieldName: fieldName,
        vehicleId: int.parse(widget.vehicleId),
        successMessage: successMessage,
      ),
    );
  }
}

enum ComplianceStatus {
  valid,
  expiringSoon,
  expired,
}
