import 'package:flutter/material.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/post_listing_provider.dart';
import 'package:shine_app/presentation/widgets/sign_in_to_access.dart';
import 'package:shine_app/presentation/widgets/post_listing/post_listing_form.dart';
import 'package:shine_app/presentation/widgets/post_listing/post_success.dart';
import 'package:provider/provider.dart';

class PostListingPage extends StatelessWidget {
  const PostListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final postListingProvider = context.watch<PostListingProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return SignInToAccess(message: 'Ready to post your listing?');
    }
    if (postListingProvider.successfulPost) {
      return PostSuccess();
    }

    return PostListingForm();
  }
}
