import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/vehicle_form_provider.dart';
import 'package:motorix_app/presentation/widgets/common/select_single_image.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/additional_info_section.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/basic_vehicle_info.dart';
import 'package:motorix_app/presentation/widgets/vehicle_form/registration_service_section.dart';
import 'package:provider/provider.dart';

enum VehicleFormMode { add, edit }

class VehicleForm extends StatefulWidget {
  final VehicleFormMode mode;

  const VehicleForm({super.key, required this.mode});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();

  String get _title => widget.mode == VehicleFormMode.add
      ? 'Add Vehicle'
      : 'Edit Vehicle';

  String get _submitButtonText => widget.mode == VehicleFormMode.add
      ? 'Add Vehicle'
      : 'Update Vehicle';

  String get _successMessage => widget.mode == VehicleFormMode.add
      ? 'Vehicle added successfully!'
      : 'Vehicle updated successfully!';

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VehicleFormProvider>();
    await provider.submitForm();

    if (!context.mounted) return;

    if (provider.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage),
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
    final provider = context.watch<VehicleFormProvider>();

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
                  _title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SelectSingleImage(
                  imageBytes: provider.vehicleImageBytes,
                  onImageSelected: provider.setVehicleImage,
                  onImageDeleted: provider.removeVehicleImage,
                  aspectRatio: 4 / 3,
                ),
                const BasicVehicleInfo(),
                const RegistrationServiceSection(),
                const AdditionalInfoSection(),
                const SizedBox(height: 20),

                // Show cancel button for edit mode
                if (widget.mode == VehicleFormMode.edit)
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/garage'),
                          child: const Text('Cancel'),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _handleSubmit(context),
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_submitButtonText),
                        ),
                      ),
                    ],
                  )
                else
                  // Just submit button for add mode
                  FilledButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => _handleSubmit(context),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_submitButtonText),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
