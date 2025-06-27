import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectMultipleImages extends StatefulWidget {
  final List<Uint8List> imageBytesList;

  const SelectMultipleImages({super.key, required this.imageBytesList});

  @override
  State<SelectMultipleImages> createState() => _SelectMultipleImagesState();
}

class _SelectMultipleImagesState extends State<SelectMultipleImages> {
  final picker = ImagePicker();

  bool canPickImage() => widget.imageBytesList.length < 10;

  Future<void> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        widget.imageBytesList.add(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text(
          'Listing Images (${widget.imageBytesList.length}/10)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        widget.imageBytesList.isNotEmpty
            ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.imageBytesList
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
                                  setState(() {
                                    widget.imageBytesList.removeAt(entry.key);
                                  });
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
        OutlinedButton.icon(
          onPressed: canPickImage() ? pickImage : null,
          icon: Icon(Icons.add_photo_alternate),
          label: Text('Pick Image'),
        ),
      ],
    );
  }
}
