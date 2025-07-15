import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/post_listing/listing_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/select_multiple_images.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_optional_fields.dart';

class PostListingPage extends StatefulWidget {
  const PostListingPage({super.key});

  @override
  State<PostListingPage> createState() => _PostListingPageState();
}

class _PostListingPageState extends State<PostListingPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 32,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                VehicleInfoFields(),
                VehicleInfoOptionalFields(),
                ListingInfoFields(),
                SelectMultipleImages(),
                SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle submission logic here
                    }
                  },
                  child: Text('Submit listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
