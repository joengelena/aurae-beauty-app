import 'package:flutter/material.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/post_listing/post_listing_form.dart';
import 'package:motorix_app/presentation/widgets/post_listing/post_success.dart';
import 'package:provider/provider.dart';

class PostListingPage extends StatelessWidget {
  const PostListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostListingProvider>();

    if (!provider.successfulPost && provider.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );

        provider.errorMessage = '';
      });
    }

    if (provider.successfulPost) {
      return PostSuccess();
    }

    return PostListingForm();
  }
}
