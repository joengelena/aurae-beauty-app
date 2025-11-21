import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/add_vehicle_provider.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/additional_info_section.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/basic_vehicle_info.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/registration_service_section.dart';
import 'package:provider/provider.dart';

class AddVehicleForm extends StatefulWidget {
  const AddVehicleForm({super.key});

  @override
  State<AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AddVehicleProvider>();
    await provider.addVehicle();

    if (!context.mounted) return;

    if (provider.successfulPost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/garage');
    } else if (provider.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddVehicleProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 32,
              children: [
                Text(
                  'Add Vehicle',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const BasicVehicleInfo(),
                const RegistrationServiceSection(),
                const AdditionalInfoSection(),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleSubmit(context),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Add Vehicle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
