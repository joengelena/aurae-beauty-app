import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/vehicle_detail_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/presentation/widgets/garage/compliance_card.dart';
import 'package:motorix_app/presentation/widgets/garage/update_expiry_date_dialog.dart';
import 'package:motorix_app/presentation/widgets/common/action_menu_button.dart';
import 'package:motorix_app/utils/utils.dart';
import 'package:motorix_app/utils/feedback_helpers.dart';
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
      final provider = context.read<VehicleDetailProvider>();
      // Clear any previous vehicle data before loading new one
      provider.clearVehicle();
      provider.getVehicle(int.parse(widget.vehicleId));
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
        'value':
            vehicle.odometerReading != null
                ? '${NumberFormat('#,###').format(vehicle.odometerReading!)} ${vehicle.odometerUnit}'
                : 'Not recorded',
      },
      {
        'icon': Icons.local_gas_station,
        'label': 'Fuel Type',
        'value': vehicle.fuelType ?? 'Not specified',
      },
      {
        'icon': Icons.settings,
        'label': 'Transmission',
        'value': vehicle.transmission ?? 'Not specified',
      },
      {
        'icon': Icons.palette,
        'label': 'Color',
        'value': vehicle.color ?? 'Not specified',
      },
    ];

    // Vehicle details
    final vehicleDetails = {
      'License Plate': vehicle.licensePlate,
      'Color': vehicle.color,
      'Fuel Type': vehicle.fuelType,
      'Transmission': vehicle.transmission,
      'Odometer':
          vehicle.odometerReading != null
              ? '${NumberFormat('#,###').format(vehicle.odometerReading!)} ${vehicle.odometerUnit}'
              : null,
      'Added': formatDate(vehicle.createdAt),
      'Last Updated': formatDate(vehicle.updatedAt),
    };

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            spacing: 12,
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

              // Title and Menu Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      ActionMenuButton(
                        options: [
                          MenuOption(
                            icon: Icons.edit,
                            title: 'Edit',
                            onTap: () {
                              context.go('/garage/${vehicle.id}/edit');
                            },
                          ),
                          MenuOption(
                            icon: Icons.delete,
                            title: 'Delete',
                            iconColor: Colors.red,
                            titleColor: Colors.red,
                            onTap: () => _handleDeleteVehicle(vehicle),
                          ),
                        ],
                      ),
                    ],
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

              // Compliance Status Cards
              Column(
                spacing: 12,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: ComplianceCard(
                          title: 'REGO expires on',
                          dateString: vehicle.regoExpiryDate,
                          onUpdate:
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
                      Expanded(
                        child: ComplianceCard(
                          title: 'WOF expires on',
                          dateString: vehicle.wofExpiryDate,
                          onUpdate:
                              () => _showUpdateExpiryDialog(
                                context,
                                title: 'Update WOF',
                                currentDate: vehicle.wofExpiryDate,
                                fieldName: 'wofExpiryDate',
                                successMessage:
                                    'WOF expiry updated successfully',
                              ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ComplianceCard(
                          title:
                              'INSURANCE provided by ${vehicle.insuranceProvider} expires on',
                          dateString: vehicle.insuranceExpiryDate,
                          onUpdate:
                              () => _showUpdateExpiryDialog(
                                context,
                                title: 'Update Insurance',
                                currentDate: vehicle.insuranceExpiryDate,
                                fieldName: 'insuranceExpiryDate',
                                successMessage:
                                    'Insurance expiry updated successfully',
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Key Specs Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children:
                    keySpecs.map((spec) {
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

              // Vehicle Details Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Vehicle Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
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

              // Notes Section (if exists)
              if (vehicle.notes != null && vehicle.notes!.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vehicle.notes!,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],

              // Maintenance Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Maintenance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _buildServiceHistorySection(context, vehicle),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
            vehicleId: int.parse(widget.vehicleId),
            successMessage: successMessage,
          ),
    );
  }

  Widget _buildServiceHistorySection(
    BuildContext context,
    UserVehicle vehicle,
  ) {
    final provider = context.watch<VehicleDetailProvider>();
    final services = provider.services;

    if (provider.isLoadingServices) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (services.isEmpty) {
      return Container(
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
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _handleAddService(vehicle.id),
                icon: const Icon(Icons.add),
                label: const Text('Service Record'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      spacing: 12,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Service',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Cost',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              // Table Rows
              ...services.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                final isLast = index == services.length - 1;

                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: isLast
                          ? BorderSide.none
                          : BorderSide(color: Colors.grey[300]!, width: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              service.serviceProviderName != null
                                  ? '${service.typeOfService} (${service.serviceProviderName})'
                                  : service.typeOfService,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yy').format(service.serviceDate),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              service.cost != null
                                  ? '\$${service.cost!.toStringAsFixed(2)}'
                                  : '-',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      if (service.notes != null && service.notes!.isNotEmpty) ...[
                        SizedBox(height: 6),
                        Text(
                          service.notes!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _handleAddService(vehicle.id),
            icon: const Icon(Icons.add),
            label: const Text('Service Record'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddService(int vehicleId) async {
    final result = await context.push('/garage/$vehicleId/add-service');

    // If service was added successfully, reload services
    if (result == true && mounted) {
      final provider = context.read<VehicleDetailProvider>();
      await provider.getServices(vehicleId);
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
        FeedbackHelpers.showSuccessSnackBar(
          context,
          'Vehicle deleted successfully',
        );
        context.go('/garage');
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
