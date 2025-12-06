import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorix_app/logic/garage_provider.dart';
import 'package:motorix_app/logic/vehicle_detail_provider.dart';
import 'package:provider/provider.dart';

class UpdateExpiryDateDialog extends StatefulWidget {
  final String title;
  final String currentDate;
  final String fieldName;
  final int vehicleId;
  final String successMessage;

  const UpdateExpiryDateDialog({
    super.key,
    required this.title,
    required this.currentDate,
    required this.fieldName,
    required this.vehicleId,
    required this.successMessage,
  });

  @override
  State<UpdateExpiryDateDialog> createState() => _UpdateExpiryDateDialogState();
}

class _UpdateExpiryDateDialogState extends State<UpdateExpiryDateDialog> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Parse current date or default to today
    try {
      selectedDate = DateTime.parse(widget.currentDate);
    } catch (e) {
      selectedDate = DateTime.now();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitDate() async {
    if (selectedDate == null) return;

    final garageProvider = context.read<GarageProvider>();
    final vehicleDetailProvider = context.read<VehicleDetailProvider>();
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    Navigator.of(context).pop();

    try {
      await garageProvider.updateVehicle(widget.vehicleId, {
        widget.fieldName: formattedDate,
      });

      // Refresh the vehicle detail page with updated data
      await vehicleDetailProvider.getVehicle(widget.vehicleId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text(widget.title)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Current expiry: ${_formatDate(widget.currentDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              selectedDate != null
                  ? 'New date: ${DateFormat('dd MMM yyyy').format(selectedDate!)}'
                  : 'Select new expiry date',
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: selectedDate == null ? null : _submitDate,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
