import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
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

  final _brandController = TextEditingController();
  final _styleController = TextEditingController();
  final _internalNameController = TextEditingController();
  final _colorController = TextEditingController();
  final _purchaseYearController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _notesController = TextEditingController();
  final _damageDescriptionController = TextEditingController();

  String _listingType = 'rent';
  bool _isPublic = false;
  String _size = 'M';
  String _condition = 'Excellent';

  Uint8List? _imageBytes;
  String? _imageMimeType;
  final List<Uint8List> _damagePhotoBytes = [];
  bool _isSubmitting = false;
  BusinessDress? _dress;

  static const _sizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '6',
    '8',
    '10',
    '12',
    '14',
    '16',
  ];
  static const _conditions = ['Excellent', 'Good', 'Fair', 'Poor'];

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

    _brandController.text = _dress!.brand;
    _styleController.text = _dress!.style;
    _internalNameController.text = _dress!.internalName ?? '';
    _colorController.text = _dress!.color ?? '';
    _purchaseYearController.text =
        _dress!.purchaseYear != null ? _dress!.purchaseYear.toString() : '';
    _rentalPriceController.text = _dress!.rentalPricePerDay?.toString() ?? '';
    _purchasePriceController.text =
        _dress!.purchasePrice != null ? _dress!.purchasePrice.toString() : '';
    _notesController.text = _dress!.notes ?? '';
    _damageDescriptionController.text = _dress!.damageDescription ?? '';

    if (_sizes.contains(_dress!.size)) {
      _size = _dress!.size;
    }
    if (_conditions.contains(_dress!.condition)) {
      _condition = _dress!.condition;
    }
    _listingType = _dress!.listingType;
    _isPublic = _dress!.isPublic;

    setState(() {});
  }

  @override
  void dispose() {
    _brandController.dispose();
    _styleController.dispose();
    _internalNameController.dispose();
    _colorController.dispose();
    _purchaseYearController.dispose();
    _rentalPriceController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    _damageDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDamagePhoto() async {
    if (_damagePhotoBytes.length >= 5) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _damagePhotoBytes.add(bytes));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mimeType = 'image/${picked.name.split('.').last.toLowerCase()}';
    setState(() {
      _imageBytes = bytes;
      _imageMimeType = mimeType;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final updates = <String, Object>{
      'brand': _brandController.text.trim(),
      'style': _styleController.text.trim(),
      'listingType': _listingType,
      'isPublic': _isPublic,
      'size': _size,
      'condition': _condition,
    };
    if (_internalNameController.text.trim().isNotEmpty) {
      updates['internalName'] = _internalNameController.text.trim();
    }
    if (_colorController.text.trim().isNotEmpty) {
      updates['color'] = _colorController.text.trim();
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
    if (_notesController.text.trim().isNotEmpty) {
      updates['notes'] = _notesController.text.trim();
    }
    if (_damageDescriptionController.text.trim().isNotEmpty) {
      updates['damageDescription'] = _damageDescriptionController.text.trim();
    }

    try {
      await context.read<WardrobeProvider>().updateDress(
        int.parse(widget.dressId),
        updates,
        imageBytes: _imageBytes,
        imageMimeType: _imageMimeType,
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
      if (mounted)
        FeedbackHelpers.showErrorSnackBar(context, 'Failed to update dress.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dress'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child:
                _isSubmitting
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
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildListingTypeToggle(),
              const SizedBox(height: 12),
              _buildVisibilityToggle(),
              const SizedBox(height: 16),
              _field(_brandController, 'Brand', required: true),
              _field(_styleController, 'Style', required: true),
              _field(
                _rentalPriceController,
                _listingType == 'sell' ? 'Selling Price' : 'Price per Day',
                keyboardType: TextInputType.number,
                required: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return _listingType == 'sell' ? 'Enter a selling price' : 'Enter a rental price';
                  if (int.tryParse(v) == null) return 'Enter a whole number';
                  return null;
                },
              ),
              _dropdown(
                'Size',
                _size,
                _sizes,
                (v) => setState(() => _size = v!),
              ),
              _field(_colorController, 'Color'),
              _field(
                _purchaseYearController,
                'Purchase Year',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final year = int.tryParse(v);
                  if (year == null || year < 1900 || year > 2100)
                    return 'Enter a valid year';
                  return null;
                },
              ),
              _field(_internalNameController, 'Internal Name'),
              const SizedBox(height: 4),
              _dropdown(
                'Condition',
                _condition,
                _conditions,
                (v) => setState(() => _condition = v!),
              ),
              const SizedBox(height: 16),
              Text(
                'Optional',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: themeText),
              ),
              const SizedBox(height: 8),
              _field(
                _purchasePriceController,
                'Purchase Price',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (int.tryParse(v) == null) return 'Enter a whole number';
                  return null;
                },
              ),
              _field(_notesController, 'Notes', maxLines: 4),
              const SizedBox(height: 8),
              _buildDamageSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFED),
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
                        ? 'Anyone can browse and book this dress'
                        : 'Only visible in your wardrobe',
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
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? themeText : themeTaupe,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDamageSection() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        initiallyExpanded:
            _dress?.damageDescription != null &&
            _dress!.damageDescription!.isNotEmpty,
        title: Text(
          'Damage Report',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: themeText),
        ),
        subtitle: Text(
          'Optional — document any existing damage',
          style: TextStyle(fontSize: 12, color: themeTaupe),
        ),
        children: [
          const SizedBox(height: 4),
          _field(
            _damageDescriptionController,
            'Describe the damage',
            maxLines: 4,
          ),
          const SizedBox(height: 4),
          _buildDamagePhotosPicker(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDamagePhotosPicker() {
    final existingUrls = _dress?.damagePhotoUrls ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Damage photos',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: themeText),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...existingUrls.map(
                (url) => Container(
                  width: 96,
                  height: 96,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: const Color(0xFFF5EFED),
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: themeTaupe,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              ..._damagePhotoBytes.asMap().entries.map(
                (e) => _damagePhotoThumbnail(e.key, e.value),
              ),
              if (existingUrls.length + _damagePhotoBytes.length < 5)
                GestureDetector(
                  onTap: _pickDamagePhoto,
                  child: Container(
                    width: 96,
                    height: 96,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EFED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDDD4CF)),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: themeTaupe,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _damagePhotoThumbnail(int index, Uint8List bytes) {
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
            onTap: () => setState(() => _damagePhotoBytes.removeAt(index)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final existingUrl = _dress?.dressPhotoUrl;
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDD4CF)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              _imageBytes != null
                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                  : existingUrl != null
                  ? Image.network(
                    existingUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _photoPlaceholder(),
                  )
                  : _photoPlaceholder(),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: themeTaupe),
        const SizedBox(height: 8),
        Text('Tap to change photo', style: TextStyle(color: themeTaupe, fontSize: 14)),
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
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
