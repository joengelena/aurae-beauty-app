import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/logic/dress_detail_provider.dart';
import 'package:shine_app/presentation/widgets/common/calendar_date_range_picker.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
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
  bool _dateError = false;

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

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) setState(() => _dateError = true);
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) return;

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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Booking details'),
                    _dropdown('Booking type', _bookingType, _bookingTypes,
                        (v) => setState(() => _bookingType = v!)),
                    _dropdown('Status', _status, _statuses,
                        (v) => setState(() => _status = v!)),
                    const SizedBox(height: 20),
                    _sectionLabel('Dates'),
                    _buildDatePicker(context),
                    if (_dateError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        child: Text(
                          'Please select both start and end dates',
                          style: TextStyle(fontSize: 12, color: themeRose),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _sectionLabel('Renter'),
                    _field(_renterNameController, 'Renter name', required: true),
                    _field(_renterEmailController, 'Email',
                        keyboardType: TextInputType.emailAddress),
                    _field(_renterPhoneController, 'Phone',
                        keyboardType: TextInputType.phone),
                    _field(_renterInstagramController, 'Instagram ID'),
                    const SizedBox(height: 20),
                    _sectionLabel('Payment'),
                    _field(
                      _totalCostController,
                      'Total cost',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        if (double.tryParse(v) == null) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    _field(
                      _depositPaidController,
                      'Deposit paid',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        if (double.tryParse(v) == null) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    _field(_notesController, 'Notes', maxLines: 3),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildSaveBar(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: themeTaupe,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final bookings = context.read<DressDetailProvider>().bookings;
    final bookedRanges = bookings
        .where((b) => b.status != 'cancelled')
        .map((b) => BookedRange(
              startDate: b.startDate,
              endDate: b.endDate,
              status: b.status,
            ))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CalendarDateRangePicker(
        initialStart: _startDate,
        initialEnd: _endDate,
        bookedRanges: bookedRanges,
        placeholder: 'Select dates',
        hasError: _dateError,
        onChanged: (start, end) {
          setState(() {
            _startDate = start;
            _endDate = end;
            if (_startDate != null && _endDate != null) _dateError = false;
          });
        },
      ),
    );
  }

  Widget _buildSaveBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 12, 16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: themeBackground,
        border: Border(
          top: BorderSide(color: themePrimary.withValues(alpha: 0.6), width: 1),
        ),
      ),
      child: FilledButton(
        onPressed: _isSubmitting ? null : _submit,
        style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Save booking'),
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
}
