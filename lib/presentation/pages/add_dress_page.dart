import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:provider/provider.dart';

class AddDressPage extends StatefulWidget {
  const AddDressPage({super.key});

  @override
  State<AddDressPage> createState() => _AddDressPageState();
}

class _AddDressPageState extends State<AddDressPage> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _styleController = TextEditingController();
  final _internalNameController = TextEditingController();
  final _colorController = TextEditingController();
  final _purchaseYearController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _notesController = TextEditingController();
  final _damageDescriptionController = TextEditingController();

  String _size = 'M';
  String _condition = 'Excellent';

  Uint8List? _imageBytes;
  String? _imageMimeType;
  final List<Uint8List> _damagePhotoBytes = [];
  bool _isSubmitting = false;

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '6', '8', '10', '12', '14', '16'];
  static const _conditions = ['Excellent', 'Good', 'Fair', 'Poor'];

  @override
  void dispose() {
    _brandController.dispose();
    _styleController.dispose();
    _internalNameController.dispose();
    _colorController.dispose();
    _purchaseYearController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    _damageDescriptionController.dispose();
    super.dispose();
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

  Future<void> _pickDamagePhoto() async {
    if (_damagePhotoBytes.length >= 5) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _damagePhotoBytes.add(bytes));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'brand': _brandController.text.trim(),
      'style': _styleController.text.trim(),
      'size': _size,
      'condition': _condition,
    };
    if (_internalNameController.text.trim().isNotEmpty) {
      data['internalName'] = _internalNameController.text.trim();
    }
    if (_colorController.text.trim().isNotEmpty) {
      data['color'] = _colorController.text.trim();
    }
    if (_purchaseYearController.text.trim().isNotEmpty) {
      data['purchaseYear'] = int.parse(_purchaseYearController.text.trim());
    }
    if (_purchasePriceController.text.trim().isNotEmpty) {
      data['purchasePrice'] = int.parse(_purchasePriceController.text.trim());
    }
    if (_notesController.text.trim().isNotEmpty) {
      data['notes'] = _notesController.text.trim();
    }
    if (_damageDescriptionController.text.trim().isNotEmpty) {
      data['damageDescription'] = _damageDescriptionController.text.trim();
    }

    try {
      await context.read<WardrobeProvider>().addDress(
        data,
        imageBytes: _imageBytes,
        imageMimeType: _imageMimeType,
      );
      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(context, 'Dress added successfully');
        context.go('/wardrobe');
      }
    } on AppException catch (e) {
      if (mounted) FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (mounted) FeedbackHelpers.showErrorSnackBar(context, 'Failed to add dress.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Dress'),
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
              _buildImagePicker(),
              const SizedBox(height: 20),
              _field(_brandController, 'Brand', required: true),
              _field(_styleController, 'Style', required: true),
              _dropdown('Size', _size, _sizes, (v) => setState(() => _size = v!)),
              _field(_colorController, 'Color'),
              _field(
                _purchaseYearController,
                'Purchase Year',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final year = int.tryParse(v);
                  if (year == null || year < 1900 || year > 2100) return 'Enter a valid year';
                  return null;
                },
              ),
              _field(_internalNameController, 'Internal Name (optional identifier)'),
              const SizedBox(height: 4),
              const Text('Condition', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              _dropdown(
                'Condition',
                _condition,
                _conditions,
                (v) => setState(() => _condition = v!),
                showLabel: false,
              ),
              const SizedBox(height: 16),
              const Text('Optional', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              _field(
                _purchasePriceController,
                'Purchase Price (cents)',
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

  Widget _buildDamageSection() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text(
          'Damage Report',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: const Text(
          'Optional — document any existing damage',
          style: TextStyle(fontSize: 12),
        ),
        children: [
          const SizedBox(height: 4),
          _field(_damageDescriptionController, 'Describe the damage', maxLines: 4),
          const SizedBox(height: 4),
          _buildDamagePhotosPicker(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDamagePhotosPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Damage photos', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._damagePhotoBytes.asMap().entries.map(
                (e) => _damagePhotoThumbnail(e.key, e.value),
              ),
              if (_damagePhotoBytes.length < 5)
                GestureDetector(
                  onTap: _pickDamagePhoto,
                  child: Container(
                    width: 96,
                    height: 96,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
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
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Add photo', style: TextStyle(color: Colors.grey)),
                ],
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
    void Function(String?) onChanged, {
    bool showLabel = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: showLabel ? label : null),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

}
