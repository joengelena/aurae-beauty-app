import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/utils/constants.dart';
import 'package:provider/provider.dart';

class SelectMultipleImages extends StatefulWidget {
  const SelectMultipleImages({super.key});

  @override
  State<SelectMultipleImages> createState() => _SelectMultipleImagesState();
}

class _SelectMultipleImagesState extends State<SelectMultipleImages> {
  Future<void> _handlePickImage(PostListingProvider provider) async {
    // Capture context values before async operation
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    final error = await provider.pickImage();

    if (error != null && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: errorColor,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text('Add Photos', style: Theme.of(context).textTheme.headlineSmall),
        provider.imageBytesList.isNotEmpty
            ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  provider.imageBytesList
                      .asMap()
                      .entries
                      .map(
                        (entry) => Stack(
                          children: [
                            SizedBox(
                              width: 150,
                              child: AspectRatio(
                                aspectRatio: AppConstants.listingImageAspectRatio,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    entry.value,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  provider.removeImage(entry.key);
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            )
            : Text('No images selected'),
        Text(
          '(${provider.imageBytesList.length}/10)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        OutlinedButton.icon(
          onPressed:
              provider.canPickImage() ? () => _handlePickImage(provider) : null,
          icon: Icon(Icons.add_photo_alternate),
          label: Text('Pick Image'),
        ),
      ],
    );
  }
}
