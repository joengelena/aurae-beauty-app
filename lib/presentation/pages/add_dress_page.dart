import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/logic/filtering_provider.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/presentation/widgets/common/calendar_date_range_picker.dart';
import 'package:shine_app/presentation/widgets/wardrobe/multi_chip_selector.dart';
import 'package:shine_app/presentation/widgets/wardrobe/picker_form_field.dart';
import 'package:shine_app/presentation/widgets/wardrobe/size_system_toggle.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class AddDressPage extends StatefulWidget {
  const AddDressPage({super.key});

  @override
  State<AddDressPage> createState() => _AddDressPageState();
}

class _AddDressPageState extends State<AddDressPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _internalNameController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _purchaseYearController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _notesController = TextEditingController();

  String _listingType = 'rent';
  DateTime? _availableFrom;
  bool _isPublic = false;
  SizeSystem _sizeSystem = SizeSystem.letter;
  List<String> _selectedSizes = [];
  bool _sizeError = false;
  String _condition = 'Excellent';
  String? _selectedColor;
  bool _colorError = false;
  bool _photoError = false;
  String _brandValue = '';
  String _styleValue = '';
  String _dressTypeValue = '';
  String _fitNoteValue = '';
  List<String> _recommendedSizes = [];

  final List<Uint8List> _photoBytes = [];
  final List<String?> _photoMimeTypes = [];
  bool _isSubmitting = false;

  static const _letterSizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _numberSizes = ['4', '6', '8', '10', '12', '14', '16'];
  static const _conditions = ['Excellent', 'Good', 'Fair', 'Poor'];
  static const _fitNotes = ['Runs small', 'True to size', 'Runs large'];

  List<String> get _sizeOptions =>
      _sizeSystem == SizeSystem.letter ? _letterSizes : _numberSizes;

  @override
  void dispose() {
    _nameController.dispose();
    _internalNameController.dispose();
    _rentalPriceController.dispose();
    _purchaseYearController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_photoBytes.length >= 10) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mimeType = 'image/${picked.name.split('.').last.toLowerCase()}';
    setState(() {
      _photoBytes.add(bytes);
      _photoMimeTypes.add(mimeType);
      _photoError = false;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photoBytes.removeAt(index);
      _photoMimeTypes.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    if (_selectedColor == null) setState(() => _colorError = true);
    if (_photoBytes.isEmpty) setState(() => _photoError = true);
    if (_selectedSizes.isEmpty) setState(() => _sizeError = true);
    if (!formValid || _selectedColor == null || _photoBytes.isEmpty || _selectedSizes.isEmpty) {
      return;
    }
    setState(() => _isSubmitting = true);

    final baseData = <String, dynamic>{
      'brand': _brandValue,
      'style': _styleValue,
      'listingType': _listingType,
      'isPublic': _isPublic,
      'condition': _condition,
      'color': _selectedColor!,
    };
    if (_nameController.text.trim().isNotEmpty) {
      baseData['name'] = _nameController.text.trim();
    }
    if (_internalNameController.text.trim().isNotEmpty) {
      baseData['internalName'] = _internalNameController.text.trim();
    }
    if (_dressTypeValue.isNotEmpty) {
      baseData['dressType'] = _dressTypeValue;
    }
    if (_fitNoteValue.isNotEmpty) {
      baseData['fitNote'] = _fitNoteValue;
    }
    if (_recommendedSizes.isNotEmpty) {
      baseData['recommendedSizes'] = _recommendedSizes;
    }
    if (_purchaseYearController.text.trim().isNotEmpty) {
      baseData['purchaseYear'] = int.parse(_purchaseYearController.text.trim());
    }
    if (_rentalPriceController.text.trim().isNotEmpty) {
      baseData['rentalPricePerDay'] = int.parse(_rentalPriceController.text.trim());
    }
    if (_purchasePriceController.text.trim().isNotEmpty) {
      baseData['purchasePrice'] = int.parse(_purchasePriceController.text.trim());
    }
    if (_listingType == 'sell' && _availableFrom != null) {
      baseData['availableFrom'] = DateFormat('yyyy-MM-dd').format(_availableFrom!);
    }
    if (_notesController.text.trim().isNotEmpty) {
      baseData['notes'] = _notesController.text.trim();
    }

    try {
      for (final size in _selectedSizes) {
        await context.read<WardrobeProvider>().addDress(
          {...baseData, 'size': size},
          photoBytes: _photoBytes,
          photoMimeTypes: _photoMimeTypes,
        );
      }
      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          context,
          _selectedSizes.length > 1
              ? '${_selectedSizes.length} dresses added successfully'
              : 'Dress added successfully',
        );
        context.go('/wardrobe');
      }
    } on AppException catch (e) {
      if (mounted) FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (mounted) {
        FeedbackHelpers.showErrorSnackBar(context, 'Failed to add dress.');
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
            Expanded(
              child: SingleChildScrollView(
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
                          label: 'Brand',
                          options: attrOptions('brand'),
                          required: true,
                          onChanged: (v) => _brandValue = v,
                        ),
                        PickerFormField(
                          label: 'Style',
                          options: attrOptions('style'),
                          required: true,
                          onChanged: (v) => _styleValue = v,
                        ),
                        PickerFormField(
                          label: 'Dress type',
                          options: attrOptions('dress_type'),
                          onChanged: (v) => _dressTypeValue = v,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizeSystemToggle(
                            value: _sizeSystem,
                            onChanged: (v) => setState(() {
                              _sizeSystem = v;
                              _selectedSizes = [];
                              _recommendedSizes = [];
                            }),
                          ),
                        ),
                        MultiChipSelector(
                          key: ValueKey(_sizeSystem),
                          label: 'Size (select all sizes you have for this design)',
                          options: _sizeOptions,
                          onChanged: (v) => setState(() {
                            _selectedSizes = v;
                            _sizeError = false;
                          }),
                        ),
                        if (_sizeError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Please select at least one size',
                              style: TextStyle(fontSize: 12, color: themeRose),
                            ),
                          ),
                        PickerFormField(
                          label: 'Recommended fit',
                          options: _fitNotes,
                          onChanged: (v) => _fitNoteValue = v,
                        ),
                        MultiChipSelector(
                          key: ValueKey('rec_$_sizeSystem'),
                          label: 'Recommended sizes (optional)',
                          options: _sizeOptions,
                          onChanged: (v) => _recommendedSizes = v,
                        ),
                        PickerFormField(
                          label: 'Condition',
                          options: _conditions,
                          initialValue: _condition,
                          onChanged: (v) => _condition = v,
                        ),
                        _buildColorPicker(),
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
                      ],
                    );
                  },
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: themeTaupe,
        ),
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
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: themeText,
                ),
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
          color: _isPublic ? themePrimary : themeSurfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPublic ? themeAccent : themeBorderMuted,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isPublic ? Icons.public : Icons.lock_outline,
              size: 20,
              color: _isPublic ? themeAccentInk : themeTaupe,
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
                      color: _isPublic ? themeAccentInk : themeText,
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
              activeColor: themeAccentInk,
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

  Widget _buildColorPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 14, color: themeText),
              children: [
                const TextSpan(text: 'Color  '),
                TextSpan(text: '*', style: TextStyle(color: themeRose)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                dressColorMap.entries.map((entry) {
                  final selected = _selectedColor == entry.key;
                  final isLight = entry.value.computeLuminance() > 0.85;
                  return GestureDetector(
                    onTap:
                        () => setState(() {
                          _selectedColor = entry.key;
                          _colorError = false;
                        }),
                    child: Tooltip(
                      message: entry.key,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border:
                              selected
                                  ? Border.all(color: themeText, width: 2.5)
                                  : isLight
                                  ? Border.all(
                                    color: themeBorderMuted,
                                    width: 0.8,
                                  )
                                  : null,
                          boxShadow:
                              selected
                                  ? [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child:
                            selected
                                ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: isLight ? themeText : Colors.white,
                                )
                                : null,
                      ),
                    ),
                  );
                }).toList(),
          ),
          if (_selectedColor != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _selectedColor!,
                style: TextStyle(fontSize: 12, color: themeTaupe),
              ),
            ),
          if (_colorError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Please select a color',
                style: TextStyle(fontSize: 12, color: themeRose),
              ),
            ),
        ],
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
              '${_photoBytes.length}/10',
              style: TextStyle(fontSize: 12, color: themeTaupe),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: _photoBytes.isEmpty
              ? GestureDetector(
                  onTap: _addPhoto,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _photoError ? themeRose.withValues(alpha: 0.06) : themeSurfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _photoError ? themeRose : themeBorderMuted,
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
                    ..._photoBytes.asMap().entries.map((e) => _photoThumbnail(e.key, e.value)),
                    if (_photoBytes.length < 10)
                      GestureDetector(
                        onTap: _addPhoto,
                        child: Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: themeSurfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: themeBorderMuted),
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

  Widget _photoThumbnail(int index, Uint8List bytes) {
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
            onTap: () => _removePhoto(index),
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

}
