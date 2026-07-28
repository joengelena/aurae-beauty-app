import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/dress_damage_incident.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/logic/dress_detail_provider.dart';
import 'package:shine_app/presentation/widgets/common/calendar_date_range_picker.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class AddDamageIncidentPage extends StatefulWidget {
  final int dressId;
  final int? incidentId;

  const AddDamageIncidentPage({super.key, required this.dressId, this.incidentId});

  @override
  State<AddDamageIncidentPage> createState() => _AddDamageIncidentPageState();
}

class _AddDamageIncidentPageState extends State<AddDamageIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _resolutionNotesController = TextEditingController();

  DressDamageIncident? _existing;
  DateTime _occurredAt = DateTime.now();
  bool _isPublic = false;
  bool _resolved = false;
  int? _bookingIdFk;

  List<String> _existingPhotoUrls = [];
  final List<Uint8List> _newPhotoBytes = [];
  final List<String?> _newPhotoMimeTypes = [];
  bool _isSubmitting = false;

  bool get _isEditing => widget.incidentId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
    }
  }

  void _prefill() {
    final incidents = context.read<DressDetailProvider>().damageIncidents;
    try {
      _existing = incidents.firstWhere((i) => i.id == widget.incidentId);
    } catch (_) {
      return;
    }

    _descriptionController.text = _existing!.description;
    _resolutionNotesController.text = _existing!.resolutionNotes ?? '';
    _occurredAt = _existing!.occurredAt;
    _isPublic = _existing!.isPublic;
    _resolved = _existing!.resolved;
    _bookingIdFk = _existing!.bookingIdFk;
    _existingPhotoUrls = List.from(_existing!.photoUrls);

    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _resolutionNotesController.dispose();
    super.dispose();
  }

  int get _totalPhotoCount => _existingPhotoUrls.length + _newPhotoBytes.length;

  Future<void> _addPhoto() async {
    if (_totalPhotoCount >= 5) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mimeType = 'image/${picked.name.split('.').last.toLowerCase()}';
    setState(() {
      _newPhotoBytes.add(bytes);
      _newPhotoMimeTypes.add(mimeType);
    });
  }

  void _removeExistingPhoto(int index) {
    setState(() => _existingPhotoUrls.removeAt(index));
  }

  void _removeNewPhoto(int index) {
    setState(() {
      _newPhotoBytes.removeAt(index);
      _newPhotoMimeTypes.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      if (_isEditing) {
        final updates = <String, dynamic>{
          'description': _descriptionController.text.trim(),
          'occurredAt': DateFormat('yyyy-MM-dd').format(_occurredAt),
          'isPublic': _isPublic,
          'resolved': _resolved,
        };
        if (_resolved && _resolutionNotesController.text.trim().isNotEmpty) {
          updates['resolutionNotes'] = _resolutionNotesController.text.trim();
        }

        await context.read<DressDetailProvider>().updateDamageIncident(
          widget.dressId,
          widget.incidentId!,
          updates,
          newPhotoBytes: _newPhotoBytes,
          newPhotoMimeTypes: _newPhotoMimeTypes,
          keepPhotoUrls: _existingPhotoUrls,
        );
      } else {
        final data = <String, dynamic>{
          'description': _descriptionController.text.trim(),
          'occurredAt': DateFormat('yyyy-MM-dd').format(_occurredAt),
          'isPublic': _isPublic,
        };
        if (_bookingIdFk != null) {
          data['bookingIdFk'] = _bookingIdFk;
        }

        await context.read<DressDetailProvider>().addDamageIncident(
          widget.dressId,
          data,
          photoBytes: _newPhotoBytes,
          photoMimeTypes: _newPhotoMimeTypes,
        );
      }

      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          context,
          _isEditing ? 'Damage report updated' : 'Damage report added',
        );
        context.go('/wardrobe/${widget.dressId}');
      }
    } on AppException catch (e) {
      if (mounted) FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (mounted) {
        FeedbackHelpers.showErrorSnackBar(context, 'Failed to save damage report.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<DressDetailProvider>().bookings;

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
                    _sectionLabel('Damage report'),
                    _field(
                      _descriptionController,
                      'Describe the damage',
                      maxLines: 4,
                      required: true,
                    ),
                    _buildOccurredAtPicker(),
                    if (!_isEditing && bookings.isNotEmpty) _buildBookingPicker(bookings),
                    const SizedBox(height: 8),
                    _buildVisibilityToggle(),
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      _buildResolvedToggle(),
                      if (_resolved) ...[
                        const SizedBox(height: 8),
                        _field(
                          _resolutionNotesController,
                          'Resolution notes (optional)',
                          maxLines: 3,
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),
                    _sectionLabel('Photos'),
                    _buildPhotoPicker(),
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

  Widget _buildOccurredAtPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalendarDateRangePicker(
        rangeMode: false,
        popup: true,
        initialStart: _occurredAt,
        placeholder: 'Date of incident',
        labelFormat: DateFormat('MMM d, yyyy'),
        onChanged: (date, _) => setState(() => _occurredAt = date ?? DateTime.now()),
      ),
    );
  }

  Widget _buildBookingPicker(List<RentalBooking> bookings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int?>(
        value: _bookingIdFk,
        decoration: const InputDecoration(labelText: 'Related booking (optional)'),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('None')),
          ...bookings.map(
            (b) => DropdownMenuItem<int?>(
              value: b.id,
              child: Text(
                '${b.renterName.isNotEmpty ? b.renterName : 'Booking #${b.id}'} · ${DateFormat('MMM d').format(b.startDate)}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (v) => setState(() => _bookingIdFk = v),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isPublic = !_isPublic),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isPublic ? const Color(0xFFEAD9D5) : const Color(0xFFF5EFED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPublic ? const Color(0xFFD4A89A) : const Color(0xFFDDD4CF),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isPublic ? Icons.public : Icons.lock_outline,
              size: 20,
              color: _isPublic ? const Color(0xFF8B4A3C) : themeTaupe,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPublic ? 'Visible on Browse' : 'Private (Wardrobe only)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isPublic ? const Color(0xFF8B4A3C) : themeText,
                    ),
                  ),
                  Text(
                    _isPublic
                        ? 'Renters can see this damage report'
                        : 'Only visible to you',
                    style: TextStyle(fontSize: 11, color: themeTaupe),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
              activeColor: const Color(0xFF8B4A3C),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolvedToggle() {
    return GestureDetector(
      onTap: () => setState(() => _resolved = !_resolved),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _resolved ? themeSage.withValues(alpha: 0.12) : const Color(0xFFF5EFED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _resolved ? themeSage.withValues(alpha: 0.4) : const Color(0xFFDDD4CF),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _resolved ? Icons.check_circle_outline : Icons.pending_outlined,
              size: 20,
              color: _resolved ? themeSage : themeTaupe,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _resolved ? 'Resolved' : 'Unresolved',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _resolved ? themeSage : themeText,
                ),
              ),
            ),
            Switch(
              value: _resolved,
              onChanged: (v) => setState(() => _resolved = v),
              activeColor: themeSage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Damage photos',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: themeText),
            ),
            const SizedBox(width: 6),
            Text(
              '$_totalPhotoCount/5',
              style: TextStyle(fontSize: 12, color: themeTaupe),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._existingPhotoUrls.asMap().entries.map(
                (e) => _existingPhotoThumbnail(e.key, e.value),
              ),
              ..._newPhotoBytes.asMap().entries.map(
                (e) => _newPhotoThumbnail(e.key, e.value),
              ),
              if (_totalPhotoCount < 5)
                GestureDetector(
                  onTap: _addPhoto,
                  child: Container(
                    width: 96,
                    height: 96,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EFED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDDD4CF)),
                    ),
                    child: Icon(Icons.add_photo_alternate_outlined, color: themeTaupe),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _existingPhotoThumbnail(int index, String url) {
    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFF5EFED),
                child: Icon(Icons.broken_image_outlined, color: themeTaupe),
              ),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 10,
          child: GestureDetector(
            onTap: () => _removeExistingPhoto(index),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _newPhotoThumbnail(int index, Uint8List bytes) {
    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2,
          right: 10,
          child: GestureDetector(
            onTap: () => _removeNewPhoto(index),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
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
            : Text(_isEditing ? 'Save changes' : 'Save damage report'),
      ),
    );
  }
}
