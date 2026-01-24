import 'package:flutter/material.dart';
import 'package:motorix_app/utils/constants.dart';

class VehicleImage extends StatelessWidget {
  final String? imageUrl;

  const VehicleImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: AppConstants.listingImageAspectRatio,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
