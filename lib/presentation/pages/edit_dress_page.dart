import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_card.dart';
import 'package:shine_app/presentation/widgets/common/calendar_date_range_picker.dart';
import 'package:shine_app/presentation/widgets/listing/availability_calendar.dart';
import 'package:shine_app/presentation/widgets/wardrobe/multi_chip_selector.dart';
import 'package:shine_app/presentation/widgets/wardrobe/picker_form_field.dart';
import 'package:shine_app/presentation/widgets/wardrobe/size_radio_selector.dart';
import 'package:shine_app/presentation/widgets/wardrobe/size_system_toggle.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class EditDressPage extends StatefulWidget {
  final String dressId;

  const EditDressPage({super.key, required this.dressId});

  @override
  State<EditDressPage> createState() => _EditDressPageState();
}

class _EditDressPageState extends State<EditDressPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _internalNameController = TextEditingController();
  final _colorController = TextEditingController();
  final _purchaseYearController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _notesController = TextEditingController();

  String _listingType = 'rent';
  DateTime? _availableFrom;
  bool _isPublic = false;
  SizeSystem _sizeSystem = SizeSystem.letter;
  String _size = 'M';
  bool _sizeError = false;
  String _condition = 'Excellent';
  String _brandValue = '';
  String _styleValue = '';
  String _dressTypeValue = '';
  String _fitNoteValue = '';
  List<String> _recommendedSizes = [];
  // ValueKeys so PickerFormField re-initialises after async prefill
  String? _brandPrefill;
  String? _stylePrefill;
  String? _dressTypePrefill;
  String? _fitNotePrefill;
  String? _sizePrefill;
  String? _conditionPrefill;

  List<String> _existingPhotoUrls = [];
  final List<Uint8List> _newPhotoBytes = [];
  final List<String?> _newPhotoMimeTypes = [];
  bool _isSubmitting = false;
  bool _photoError = false;
  BusinessDress? _dress;

  List<DateTimeRange> _blockedDateRanges = [];
  bool _addingBlockedDates = false;
  DateTime? _pendingStart;
  DateTime? _pendingEnd;

  static const _letterSizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _numberSizes = ['4', '6', '8', '10', '12', '14', '16'];
  static const _sizes = [..._letterSizes, ..._numberSizes];
  static const _conditions = ['Excellent', 'Good', 'Fair', 'Poor'];
  static const _fitNotes = ['Runs small', 'True to size', 'Runs large'];

  List<String> get _sizeOptions =>
      _sizeSystem == SizeSystem.letter ? _letterSizes : _numberSizes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  void _prefill() {
    final id = int.tryParse(widget.dressId);
    if (id == null) return;

    final dresses = context.read<WardrobeProvider>().dresses;
    try {
      _dress = dresses.firstWhere((d) => d.id == id);
    } catch (_) {
      return;
    }

    _nameController.text = _dress!.name ?? '';
    _brandValue = _dress!.brand;
    _brandPrefill = _dress!.brand;
    _styleValue = _dress!.style;
    _stylePrefill = _dress!.style;
    _dressTypeValue = _dress!.dressType ?? '';
    _dressTypePrefill = _dress!.dressType;
    _fitNoteValue = _dress!.fitNote ?? '';
    _fitNotePrefill = _dress!.fitNote;
    _recommendedSizes = List.from(_dress!.recommendedSizes);
    _internalNameController.text = _dress!.internalName ?? '';
    _colorController.text = _dress!.color ?? '';
    _purchaseYearController.text =
        _dress!.purchaseYear != null ? _dress!.purchaseYear.toString() : '';
    _rentalPriceController.text = _dress!.rentalPricePerDay?.toString() ?? '';
    _purchasePriceController.text =
        _dress!.purchasePrice != null ? _dress!.purchasePrice.toString() : '';
    _notesController.text = _dress!.notes ?? '';

    if (_sizes.contains(_dress!.size)) {
      _size = _dress!.size;
      _sizePrefill = _dress!.size;
      _sizeSystem = _numberSizes.contains(_dress!.size) ? SizeSystem.number : SizeSystem.letter;
    }
    if (_conditions.contains(_dress!.condition)) {
      _condition = _dress!.condition;
      _conditionPrefill = _dress!.condition;
    }
    _listingType = _dress!.listingType;
    _availableFrom = _dress!.availableFrom;
    _isPublic = _dress!.isPublic;
    _existingPhotoUrls = List.from(_dress!.dressPhotoUrls);
    _blockedDateRanges = List.from(_dress!.blockedDateRanges);

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _internalNameController.dispose();
    _colorController.dispose();
    _purchaseYearController.dispose();
    _rentalPriceController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _totalPhotoCount => _existingPhotoUrls.length + _newPhotoBytes.length;

  Future<void> _addPhoto() async {
    if (_totalPhotoCount >= 10) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mimeType = 'image/${picked.name.split('.').last.toLowerCase()}';
    setState(() {
      _newPhotoBytes.add(bytes);
      _newPhotoMimeTypes.add(mimeType);
      _photoError = false;
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
    if (_totalPhotoCount == 0) setState(() => _photoError = true);
    if (_size.isEmpty) setState(() => _sizeError = true);
    if (!_formKey.currentState!.validate() || _totalPhotoCount == 0 || _size.isEmpty) {
      return;
    }
    setState(() => _isSubmitting = true);

    final updates = <String, Object>{
      'brand': _brandValue,
      'style': _styleValue,
      'listingType': _listingType,
      'isPublic': _isPublic,
      'size': _size,
      'condition': _condition,
    };
    if (_nameController.text.trim().isNotEmpty) {
      updates['name'] = _nameController.text.trim();
    }
    if (_internalNameController.text.trim().isNotEmpty) {
      updates['internalName'] = _internalNameController.text.trim();
    }
    if (_colorController.text.trim().isNotEmpty) {
      updates['color'] = _colorController.text.trim();
    }
    if (_dressTypeValue.isNotEmpty) {
      updates['dressType'] = _dressTypeValue;
    }
    if (_fitNoteValue.isNotEmpty) {
      updates['fitNote'] = _fitNoteValue;
    }
    if (_recommendedSizes.isNotEmpty) {
      updates['recommendedSizes'] = _recommendedSizes;
    }
    if (_purchaseYearController.text.trim().isNotEmpty) {
      updates['purchaseYear'] = int.parse(_purchaseYearController.text.trim());
    }
    if (_rentalPriceController.text.trim().isNotEmpty) {
      updates['rentalPricePerDay'] = int.parse(
        _rentalPriceController.text.trim(),
      );
    }
    if (_purchasePriceController.text.trim().isNotEmpty) {
      updates['purchasePrice'] = int.parse(
        _purchasePriceController.text.trim(),
      );
    }
    if (_listingType == 'sell' && _availableFrom != null) {
      updates['availableFrom'] = DateFormat('yyyy-MM-dd').format(_availableFrom!);
    }
    if (_notesController.text.trim().isNotEmpty) {
      updates['notes'] = _notesController.text.trim();
    }

    try {
      await context.read<WardrobeProvider>().updateDress(
        int.parse(widget.dressId),
        updates,
        newPhotoBytes: _newPhotoBytes,
        newPhotoMimeTypes: _newPhotoMimeTypes,
        keepPhotoUrls: _existingPhotoUrls,
        blockedDateRanges: _blockedDateRanges,
      );
      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          context,
          'Dress updated successfully',
        );
        context.go('/wardrobe');
      }
    } on AppException catch (e) {
      if (mounted) FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (mounted) {
        FeedbackHelpers.showErrorSnackBar(context, 'Failed to update dress.');
      }
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
          Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Builder(
            builder: (context) {
              final attrs = context.watch<FilteringProvider>().listingAttributeOptions;
              List<String> attrOptions(String name) {
                final vals = attrs
                    .where((a) => a.name == name)
                    .expand((a) => a.attributeValues.where((v) => v != 'Any'))
                    .toList();
                if (!vals.contains('Other')) vals.add('Other');
                return vals;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  _buildListingTypeToggle(),
                  const SizedBox(height: 12),
                  _buildVisibilityToggle(),
                  const SizedBox(height: 20),
                  _sectionLabel('Dress details'),
                  PickerFormField(
                    key: ValueKey(_brandPrefill),
                    label: 'Brand',
                    options: attrOptions('brand'),
                    initialValue: _brandPrefill,
                    required: true,
                    onChanged: (v) => _brandValue = v,
                  ),
                  PickerFormField(
                    key: ValueKey(_stylePrefill),
                    label: 'Style',
                    options: attrOptions('style'),
                    initialValue: _stylePrefill,
                    required: true,
                    onChanged: (v) => _styleValue = v,
                  ),
                  PickerFormField(
                    key: ValueKey(_dressTypePrefill),
                    label: 'Dress type',
                    options: attrOptions('dress_type'),
                    initialValue: _dressTypePrefill,
                    onChanged: (v) => _dressTypeValue = v,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizeSystemToggle(
                      value: _sizeSystem,
                      onChanged: (v) => setState(() {
                        _sizeSystem = v;
                        _size = '';
                        _sizePrefill = null;
                        _recommendedSizes = [];
                      }),
                    ),
                  ),
                  SizeRadioSelector(
                    key: ValueKey('${_sizePrefill}_$_sizeSystem'),
                    label: 'Size',
                    options: _sizeOptions,
                    initialValue: _sizePrefill,
                    onChanged: (v) => setState(() {
                      _size = v;
                      _sizeError = false;
                    }),
                  ),
                  if (_sizeError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Please select a size',
                        style: TextStyle(fontSize: 12, color: themeRose),
                      ),
                    ),
                  PickerFormField(
                    key: ValueKey(_fitNotePrefill),
                    label: 'Recommended fit',
                    options: _fitNotes,
                    initialValue: _fitNotePrefill,
                    onChanged: (v) => _fitNoteValue = v,
                  ),
                  MultiChipSelector(
                    key: ValueKey('rec_$_sizeSystem'),
                    label: 'Recommended sizes (optional)',
                    options: _sizeOptions,
                    initialValues: _recommendedSizes,
                    onChanged: (v) => _recommendedSizes = v,
                  ),
                  PickerFormField(
                    key: ValueKey(_conditionPrefill),
                    label: 'Condition',
                    options: _conditions,
                    initialValue: _conditionPrefill ?? _condition,
                    onChanged: (v) => _condition = v,
                  ),
                  _field(_colorController, 'Color'),
                  const SizedBox(height: 8),
                  _sectionLabel('Pricing'),
                  _field(
                    _rentalPriceController,
                    _listingType == 'sell' ? 'Selling price' : 'Price per day',
                    keyboardType: TextInputType.number,
                    required: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return _listingType == 'sell' ? 'Enter a selling price' : 'Enter a rental price';
                      if (int.tryParse(v) == null) return 'Enter a whole number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _sectionLabel('More details'),
                  _field(_nameController, 'Listing name (shown publicly)'),
                  _field(
                    _purchaseYearController,
                    'Purchase year',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final year = int.tryParse(v);
                      if (year == null || year < 1900 || year > 2100) {
                        return 'Enter a valid year';
                      }
                      return null;
                    },
                  ),
                  _field(_internalNameController, 'Internal name (private)'),
                  _field(
                    _purchasePriceController,
                    'Purchase price',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (int.tryParse(v) == null) return 'Enter a whole number';
                      return null;
                    },
                  ),
                  if (_listingType == 'sell') _buildAvailableFromPicker(),
                  _field(_notesController, 'Notes', maxLines: 4),
                  const SizedBox(height: 8),
                  _buildBlockedDatesSection(),
                  const SizedBox(height: 8),
                ],
              );
            },
          )),
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
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: themeTaupe),
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
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: themeText),
              )
            : const Text('Save dress'),
      ),
    );
  }

  Widget _buildListingTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: themeSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleOption('rent', 'For Rent'),
          _toggleOption('sell', 'For Sale'),
        ],
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isPublic = !_isPublic),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isPublic ? const Color(0xFFEAD9D5) : themeSurfaceMuted,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isPublic ? const Color(0xFF8B4A3C) : themeText,
                    ),
                  ),
                  Text(
                    _isPublic
                        ? 'Anyone can browse and book this dress'
                        : 'Only visible in your wardrobe',
                    style: TextStyle(fontSize: 12, color: themeTaupe),
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

  Widget _toggleOption(String value, String label) {
    final selected = _listingType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _listingType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? themeText : themeTaupe,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Photos',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: themeText),
            ),
            const SizedBox(width: 6),
            Text(
              '$_totalPhotoCount/10',
              style: TextStyle(fontSize: 12, color: themeTaupe),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: (_existingPhotoUrls.isEmpty && _newPhotoBytes.isEmpty)
              ? GestureDetector(
                  onTap: _addPhoto,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _photoError ? themeRose.withValues(alpha: 0.06) : themeSurfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _photoError ? themeRose : const Color(0xFFDDD4CF),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 32, color: _photoError ? themeRose : themeTaupe),
                        const SizedBox(height: 6),
                        Text('Add photos (min 1)', style: TextStyle(color: _photoError ? themeRose : themeTaupe, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingPhotoUrls.asMap().entries.map(
                      (e) => _existingPhotoThumbnail(e.key, e.value),
                    ),
                    ..._newPhotoBytes.asMap().entries.map(
                      (e) => _newPhotoThumbnail(e.key, e.value),
                    ),
                    if (_totalPhotoCount < 10)
                      GestureDetector(
                        onTap: _addPhoto,
                        child: Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: themeSurfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFDDD4CF)),
                          ),
                          child: Icon(Icons.add_photo_alternate_outlined, color: themeTaupe),
                        ),
                      ),
                  ],
                ),
        ),
        if (_photoError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Please add at least one photo',
              style: TextStyle(fontSize: 12, color: themeRose),
            ),
          ),
      ],
    );
  }

  Widget _existingPhotoThumbnail(int index, String url) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: themeSurfaceMuted,
                child: Icon(Icons.broken_image_outlined, color: themeTaupe),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => _removeExistingPhoto(index),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(3),
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
          width: 120,
          height: 120,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => _removeNewPhoto(index),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(3),
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
        validator:
            validator ??
            (required
                ? (v) =>
                    (v == null || v.trim().isEmpty)
                        ? '$label is required'
                        : null
                : null),
      ),
    );
  }

  Widget _buildAvailableFromPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalendarDateRangePicker(
        rangeMode: false,
        popup: true,
        initialStart: _availableFrom,
        placeholder: 'Purchasable immediately',
        labelFormat: DateFormat('MMM d, yyyy'),
        onChanged: (date, _) => setState(() => _availableFrom = date),
      ),
    );
  }

  // ─── Blocked dates ────────────────────────────────────────────────────────

  void _onBlockedDayTapped(DateTime day) {
    setState(() {
      final d = DateTime(day.year, day.month, day.day);
      if (_pendingStart == null || _pendingEnd != null) {
        _pendingStart = d;
        _pendingEnd = null;
      } else if (d.isBefore(_pendingStart!)) {
        _pendingStart = d;
      } else if (d == _pendingStart) {
        _pendingStart = null;
      } else {
        _pendingEnd = d;
        _blockedDateRanges.add(DateTimeRange(start: _pendingStart!, end: _pendingEnd!));
        _pendingStart = null;
        _pendingEnd = null;
        _addingBlockedDates = false;
      }
    });
  }

  Widget _buildBlockedDatesSection() {
    final fmt = DateFormat('d MMM');
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        initiallyExpanded: _blockedDateRanges.isNotEmpty,
        title: Text(
          'Unavailable dates',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: themeText),
        ),
        subtitle: Text(
          'Block dates when this dress is unavailable for rent',
          style: TextStyle(fontSize: 12, color: themeTaupe),
        ),
        children: [
          const SizedBox(height: 4),

          // Existing blocked ranges
          ..._blockedDateRanges.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: themeAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeAccent.withValues(alpha: 0.28)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_busy_outlined, size: 16, color: themeAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${fmt.format(r.start)} – ${fmt.format(r.end)}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeText),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _blockedDateRanges.removeAt(i)),
                      child: Icon(Icons.close, size: 16, color: themeTaupe),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Calendar or "Add dates" button
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: _addingBlockedDates
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: AvailabilityCalendar(
                          bookedRanges: _blockedDateRanges
                              .map((r) => BookedRange(
                                    startDate: r.start,
                                    endDate: r.end,
                                    status: 'blocked',
                                  ))
                              .toList(),
                          selectionStart: _pendingStart,
                          selectionEnd: _pendingEnd,
                          onDayTapped: _onBlockedDayTapped,
                          showLegend: false,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() {
                            _addingBlockedDates = false;
                            _pendingStart = null;
                            _pendingEnd = null;
                          }),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () => setState(() {
                      _addingBlockedDates = true;
                      _pendingStart = null;
                      _pendingEnd = null;
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: themeAccent),
                          const SizedBox(width: 6),
                          Text(
                            'Add dates',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: themeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

}
