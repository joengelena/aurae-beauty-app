import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/post_listing/listing_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/select_multiple_images.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_fields.dart';
import 'package:motorix_app/presentation/widgets/post_listing/vehicle_info_optional_fields.dart';
import 'package:provider/provider.dart';

class PostListingForm extends StatefulWidget {
  const PostListingForm({super.key});

  @override
  State<PostListingForm> createState() => _PostListingFormState();
}

class _PostListingFormState extends State<PostListingForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PostListingProvider>();

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
                  onPressed:
                      provider.isLoading
                          ? null // disables the button when loading
                          : () {
                            if (_formKey.currentState!.validate()) {
                              provider.postListing();
                            }
                          },
                  child:
                      provider.isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                          : Text('Submit listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
