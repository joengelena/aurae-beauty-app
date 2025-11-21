import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isSignedIn) {
        context.read<GarageProvider>().fetchVehicles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(message: 'Sign in to access your garage.');
    }

    final garageProvider = context.watch<GarageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garage'),
      ),
      body: _buildBody(garageProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/garage/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(GarageProvider garageProvider) {
    if (garageProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (garageProvider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                garageProvider.errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => garageProvider.fetchVehicles(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (garageProvider.vehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                'No Vehicles Yet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add your first vehicle to start tracking WOF, registration, and service dates',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => garageProvider.fetchVehicles(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: garageProvider.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = garageProvider.vehicles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                      if (vehicle.vehiclePhotoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            vehicle.vehiclePhotoUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.directions_car,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Registration',
                          vehicle.regoExpiryDate != null
                              ? _formatDate(vehicle.regoExpiryDate!)
                              : 'Not set',
                          _isExpiringSoon(vehicle.regoExpiryDate),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'WOF',
                          vehicle.wofExpiryDate != null
                              ? _formatDate(vehicle.wofExpiryDate!)
                              : 'Not set',
                          _isExpiringSoon(vehicle.wofExpiryDate),
                        ),
                      ),
                    ],
                  ),
                  if (vehicle.odometerReading != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      context,
                      'Odometer',
                      '${vehicle.odometerReading} ${vehicle.odometerUnit}',
                      false,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, bool isWarning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
          ),
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

  bool _isExpiringSoon(String? dateString) {
    if (dateString == null) return false;
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
