import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  // File? _imageFile;
  Uint8List? _imageBytes;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _imageBytes = bytes;
      });

      setState(() {
        // _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    // final response = await CloudinaryServices.uploadImage(_imageFile!);

    // setState(() {
    //   _uploadedImageUrl = response!['secure_url'];
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Listing Images',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        _imageBytes != null
            ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              ),
            )
            : Text('No image selected'),
        OutlinedButton(onPressed: pickImage, child: Text('Pick Image')),
      ],
    );
  }
}
