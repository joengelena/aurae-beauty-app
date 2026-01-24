import 'package:flutter/material.dart';
import 'package:motorix_app/data/models/user_vehicle.dart';
import 'package:motorix_app/logic/vehicle_detail_provider.dart';
import 'package:motorix_app/presentation/widgets/garage/add_service_button.dart';
import 'package:motorix_app/presentation/widgets/garage/compliance_card.dart';
import 'package:motorix_app/presentation/widgets/garage/service_history_table.dart';
import 'package:motorix_app/presentation/widgets/garage/update_expiry_date_dialog.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_action_menu.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_image.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_spec_card.dart';
import 'package:motorix_app/presentation/widgets/garage/vehicle_title.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:motorix_app/utils/utils.dart';
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
            Icon(Icons.error_outline, size: 64, color: themeRed),
            SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Vehicle not found',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return _buildDetailPage(context, vehicle);
  }

  Widget _buildDetailPage(BuildContext context, UserVehicle vehicle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            spacing: 12,
            children: [
              VehicleImage(imageUrl: vehicle.vehiclePhotoUrl),

              // Title and Menu Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: VehicleTitle(vehicle: vehicle)),
                      VehicleActionMenu(
                        vehicle: vehicle,
                        redirectAfterDelete: true,
                      ),
                    ],
                  ),
                  if (vehicle.licensePlate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      vehicle.licensePlate!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              _buildComplianceCards(vehicle),

              _buildSpecsGrid(vehicle),

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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            const Text(
              'No service history yet',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            AddServiceButton(vehicleId: vehicle.id),
          ],
        ),
      );
    }

    return Column(
      spacing: 12,
      children: [
        ServiceHistoryTable(services: services),
        AddServiceButton(vehicleId: vehicle.id),
      ],
    );
  }

  Widget _buildComplianceCards(UserVehicle vehicle) {
    return Column(
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: ComplianceCard(
                title: 'Registration',
                dateString: vehicle.regoExpiryDate,
                onUpdate:
                    () => _showUpdateExpiryDialog(
                      context,
                      title: 'Update Registration Expiry',
                      currentDate: vehicle.regoExpiryDate,
                      fieldName: 'regoExpiryDate',
                      successMessage:
                          'Registration expiry updated successfully',
                    ),
              ),
            ),
            Expanded(
              child: ComplianceCard(
                title: 'WOF',
                dateString: vehicle.wofExpiryDate,
                onUpdate:
                    () => _showUpdateExpiryDialog(
                      context,
                      title: 'Update WOF Expiry',
                      currentDate: vehicle.wofExpiryDate,
                      fieldName: 'wofExpiryDate',
                      successMessage: 'WOF expiry updated successfully',
                    ),
              ),
            ),
          ],
        ),
        ComplianceCard(
          title: 'Insurance',
          dateString: vehicle.insuranceExpiryDate,
          description: vehicle.insuranceProvider,
          onUpdate:
              () => _showUpdateExpiryDialog(
                context,
                title: 'Update Insurance Expiry',
                currentDate: vehicle.insuranceExpiryDate,
                fieldName: 'insuranceExpiryDate',
                successMessage: 'Insurance expiry updated successfully',
              ),
        ),
      ],
    );
  }

  Widget _buildSpecsGrid(UserVehicle vehicle) {
    final specs = <Map<String, dynamic>>[];

    if (vehicle.color != null) {
      specs.add({
        'icon': Icons.palette,
        'label': 'Color',
        'value': vehicle.color,
      });
    }

    if (vehicle.fuelType != null) {
      specs.add({
        'icon': Icons.local_gas_station,
        'label': 'Fuel Type',
        'value': vehicle.fuelType,
      });
    }

    if (vehicle.transmission != null) {
      specs.add({
        'icon': Icons.settings,
        'label': 'Transmission',
        'value': vehicle.transmission,
      });
    }

    if (vehicle.odometerReading != null) {
      specs.add({
        'icon': Icons.speed,
        'label': 'Odometer',
        'value':
            '${formatNumber(vehicle.odometerReading.toString())} ${vehicle.odometerUnit}',
      });
    }

    if (specs.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 60,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return VehicleSpecCard(
          icon: spec['icon'],
          label: spec['label'],
          value: spec['value'],
        );
      },
    );
  }
}
