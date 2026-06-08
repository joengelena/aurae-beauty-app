import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/logic/dress_detail_provider.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class AddBookingPage extends StatefulWidget {
  final int dressId;

  const AddBookingPage({super.key, required this.dressId});

  @override
  State<AddBookingPage> createState() => _AddBookingPageState();
}

class _AddBookingPageState extends State<AddBookingPage> {
  final _formKey = GlobalKey<FormState>();

  final _renterNameController = TextEditingController();
  final _renterEmailController = TextEditingController();
  final _renterPhoneController = TextEditingController();
  final _renterInstagramController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _depositPaidController = TextEditingController();
  final _notesController = TextEditingController();

  String _bookingType = 'rental';
  String _status = 'pending';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  static const _bookingTypes = ['rental', 'event', 'photoshoot', 'other'];
  static const _statuses = ['pending', 'confirmed', 'active', 'returned'];

  @override
  void dispose() {
    _renterNameController.dispose();
    _renterEmailController.dispose();
    _renterPhoneController.dispose();
    _renterInstagramController.dispose();
    _totalCostController.dispose();
    _depositPaidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      FeedbackHelpers.showErrorSnackBar(context, 'Please select start and end dates.');
      return;
    }

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'dressIdFk': widget.dressId,
      'bookingType': _bookingType,
      'bookingDate': DateTime.now().toIso8601String().substring(0, 10),
      'startDate': _startDate!.toIso8601String().substring(0, 10),
      'endDate': _endDate!.toIso8601String().substring(0, 10),
      'totalCost': double.tryParse(_totalCostController.text.trim()) ?? 0.0,
      'status': _status,
      'renterName': _renterNameController.text.trim(),
    };
    if (_renterEmailController.text.trim().isNotEmpty) {
      data['renterEmail'] = _renterEmailController.text.trim();
    }
    if (_renterPhoneController.text.trim().isNotEmpty) {
      data['renterPhone'] = _renterPhoneController.text.trim();
    }
    if (_renterInstagramController.text.trim().isNotEmpty) {
      data['renterInstagram'] = _renterInstagramController.text.trim();
    }
    if (_depositPaidController.text.trim().isNotEmpty) {
      data['depositPaid'] = double.parse(_depositPaidController.text.trim());
    }
    if (_notesController.text.trim().isNotEmpty) {
      data['notes'] = _notesController.text.trim();
    }

    try {
      await context.read<DressDetailProvider>().addBooking(data);
      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(context, 'Booking added successfully');
        context.go('/wardrobe/${widget.dressId}');
      }
    } on AppException catch (e) {
      if (mounted) FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (mounted) FeedbackHelpers.showErrorSnackBar(context, 'Failed to add booking.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Booking'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dropdown('Booking Type', _bookingType, _bookingTypes,
                  (v) => setState(() => _bookingType = v!)),
              _dropdown('Status', _status, _statuses,
                  (v) => setState(() => _status = v!)),
              const SizedBox(height: 16),
              Text('Dates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: themeText)),
              const SizedBox(height: 8),
              _datePicker('Start Date *', _startDate, _pickStartDate),
              _datePicker('End Date *', _endDate, _pickEndDate),
              const SizedBox(height: 16),
              Text('Renter', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: themeText)),
              const SizedBox(height: 8),
              _field(_renterNameController, 'Renter Name', required: true),
              _field(_renterEmailController, 'Renter Email',
                  keyboardType: TextInputType.emailAddress),
              _field(_renterPhoneController, 'Renter Phone',
                  keyboardType: TextInputType.phone),
              _field(_renterInstagramController, 'Instagram ID',
                  keyboardType: TextInputType.text),
              const SizedBox(height: 16),
              Text('Payment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: themeText)),
              const SizedBox(height: 8),
              _field(
                _totalCostController,
                'Total Cost',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (double.tryParse(v) == null) return 'Enter a valid amount';
                  return null;
                },
              ),
              _field(
                _depositPaidController,
                'Deposit Paid',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (double.tryParse(v) == null) return 'Enter a valid amount';
                  return null;
                },
              ),
              _field(_notesController, 'Notes', maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
                : null),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(
            date != null ? formatDate(date) : 'Select date',
            style: TextStyle(color: date != null ? themeText : themeTaupe),
          ),
        ),
      ),
    );
  }
}
