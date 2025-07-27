import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class SelectMultipleImages extends StatefulWidget {
  const SelectMultipleImages({super.key});

  @override
  State<SelectMultipleImages> createState() => _SelectMultipleImagesState();
}

class _SelectMultipleImagesState extends State<SelectMultipleImages> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    return Column(
      spacing: 12,
      children: [
        Text(
          'Add Photos',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                entry.value,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
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
          onPressed: provider.canPickImage() ? provider.pickImage : null,
          icon: Icon(Icons.add_photo_alternate),
          label: Text('Pick Image'),
        ),
      ],
    );
  }
}
