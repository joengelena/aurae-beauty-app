import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/service_form_provider.dart';
import 'package:motorix_app/presentation/widgets/common/loading_button.dart';
import 'package:motorix_app/presentation/widgets/form_fields/date_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/decimal_form_field.dart';
import 'package:motorix_app/presentation/widgets/form_fields/dropdown_form_field.dart';
import 'package:provider/provider.dart';

enum ServiceFormMode { add, edit }

class ServiceForm extends StatefulWidget {
  final ServiceFormMode mode;

  const ServiceForm({super.key, required this.mode});

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _serviceProviderController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _serviceTypes = [
    'Oil Change',
    'Tire Rotation',
    'Brake Service',
    'Battery Replacement',
    'Air Filter Replacement',
    'Transmission Service',
    'Coolant Flush',
    'Spark Plug Replacement',
    'Wheel Alignment',
    'General Maintenance',
    'Other',
  ];

  String get _title => widget.mode == ServiceFormMode.add
      ? 'Add Service'
      : 'Edit Service';

  String get _submitButtonText => widget.mode == ServiceFormMode.add
      ? 'Add Service Record'
      : 'Update Service Record';

  String get _successMessage => widget.mode == ServiceFormMode.add
      ? 'Service record added successfully!'
      : 'Service record updated successfully!';

  @override
  void dispose() {
    _serviceProviderController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ServiceFormProvider>();

    // Add optional text fields to form data
    final serviceProviderName = _serviceProviderController.text.trim();
    if (serviceProviderName.isNotEmpty) {
      provider.formData['serviceProviderName'] = serviceProviderName;
    }

    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) {
      provider.formData['notes'] = notes;
    }

    await provider.submitForm();

    if (!context.mounted) return;

    if (provider.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(true);
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
    final provider = context.watch<ServiceFormProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 24,
              children: [
                Text(
                  _title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                // Vehicle Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.vehicle.year} ${provider.vehicle.make} ${provider.vehicle.model}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (provider.vehicle.licensePlate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'License Plate: ${provider.vehicle.licensePlate}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Service Type Dropdown
                DropdownFormField<ServiceFormProvider>(
                  labelText: 'Service Type',
                  fieldName: 'typeOfService',
                  options: _serviceTypes,
                  isRequired: true,
                ),

                // Service Date
                DateFormField<ServiceFormProvider>(
                  labelText: 'Service Date',
                  fieldName: 'serviceDate',
                  isRequired: true,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                ),

                // Service Provider Name
                TextFormField(
                  controller: _serviceProviderController,
                  decoration: const InputDecoration(
                    labelText: 'Service Provider (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                    hintText: 'e.g., AutoPro, Bob\'s Garage',
                  ),
                  maxLength: 150,
                  textCapitalization: TextCapitalization.words,
                ),

                // Cost
                DecimalFormField<ServiceFormProvider>(
                  labelText: 'Cost (Optional)',
                  fieldName: 'cost',
                  prefixText: '\$',
                  prefixIcon: Icons.attach_money,
                  hintText: '0.00',
                  min: 0,
                ),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),

                const SizedBox(height: 20),

                // Show cancel button for edit mode
                if (widget.mode == ServiceFormMode.edit)
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: LoadingButton(
                          onPressed: () => context.pop(),
                          label: 'Cancel',
                          isOutlined: true,
                        ),
                      ),
                      Expanded(
                        child: LoadingButton(
                          onPressed: () => _handleSubmit(context),
                          label: _submitButtonText,
                          isLoading: provider.isLoading,
                        ),
                      ),
                    ],
                  )
                else
                  // Just submit button for add mode
                  SizedBox(
                    width: double.infinity,
                    child: LoadingButton(
                      onPressed: () => _handleSubmit(context),
                      label: _submitButtonText,
                      isLoading: provider.isLoading,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
