import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';

class SelectSingleImage extends StatefulWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final void Function(Uint8List imageBytes, String mimeType) onImageSelected;
  final VoidCallback onImageDeleted;
  final double aspectRatio;

  const SelectSingleImage({
    super.key,
    this.imageBytes,
    this.imageUrl,
    required this.onImageSelected,
    required this.onImageDeleted,
    this.aspectRatio = AppConstants.listingImageAspectRatio,
  });

  @override
  State<SelectSingleImage> createState() => _SelectSingleImageState();
}

class _SelectSingleImageState extends State<SelectSingleImage> {
  static const int _maxFileSizeBytes =
      10 * 1024 * 1024; // 10MB (matches backend)
  static const double _maxImageWidth = 1920;
  static const double _maxImageHeight = 1080;
  static const int _imageQuality = 85;

  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxImageWidth,
        maxHeight: _maxImageHeight,
        imageQuality: _imageQuality,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (bytes.length > _maxFileSizeBytes) {
        _showError('Image must be less than 10MB');
        return;
      }

      // Get MIME type from the file, default to image/jpeg if not available
      final mimeType = image.mimeType ?? 'image/jpeg';

      widget.onImageSelected(bytes, mimeType);
    } catch (e) {
      _showError('Failed to select image');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    FeedbackHelpers.showErrorSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageBytes != null || widget.imageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        hasImage ? _buildImagePreview() : _buildEmptyState(context),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                widget.imageBytes != null
                    ? Image.memory(
                      widget.imageBytes!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                    : CachedNetworkImage(
                      imageUrl: widget.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return Container(
                          color: themeSurfaceMuted,
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: themeTaupe,
                          ),
                        );
                      },
                    ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: widget.onImageDeleted,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.close, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final outlineColor = Theme.of(context).colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: outlineColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: outlineColor),
            const SizedBox(height: 8),
            Text(
              'No image selected',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: outlineColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final hasImage = widget.imageBytes != null || widget.imageUrl != null;

    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _pickImage,
      icon:
          _isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Icon(hasImage ? Icons.edit : Icons.add_photo_alternate),
      label: Text(hasImage ? 'Change Image' : 'Select Image'),
    );
  }
}
