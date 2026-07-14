import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/edit_listing_provider.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/logic/user_listings_provider.dart';
import 'package:shine_app/presentation/widgets/edit_listing/edit_listing_form.dart';
import 'package:shine_app/logic/listing_form_data_provider.dart';
import 'package:shine_app/presentation/widgets/sign_in_to_access.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/secure_storage.dart';
import 'package:provider/provider.dart';

class EditListingPage extends StatefulWidget {
  const EditListingPage({super.key, required this.listingId});
  final String listingId;

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  bool _hasNavigatedBack = false;
  String? _currentUserId;
  bool _isLoadingUserId = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndListing();
  }

  Future<void> _loadUserIdAndListing() async {
    try {
      final userId = await SecureStorage.read('userId');
      if (mounted) {
        setState(() {
          _currentUserId = userId;
          _isLoadingUserId = false;
        });

        // Load listing if not already loaded
        final listingProvider = context.read<ListingDetailProvider>();
        if (listingProvider.listing?.id.toString() != widget.listingId) {
          listingProvider.getListing(int.parse(widget.listingId));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserId = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final listingDetailProvider = context.watch<ListingDetailProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(
        icon: Icons.edit_outlined,
        title: 'Sign in to continue',
        subtitle: 'You need to be signed in to edit a listing.',
      );
    }

    if (_isLoadingUserId || listingDetailProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_currentUserId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Unable to verify user identity'),
            SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: Text('Go to Home'),
            ),
          ],
        ),
      );
    }

    final listing = listingDetailProvider.listing;

    if (listing == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Listing not found'),
            SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: Text('Go to Home'),
            ),
          ],
        ),
      );
    }

    // Check if user owns this listing
    if (listing.userIdFk != _currentUserId) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            Text(
              'You can only edit your own listings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            FilledButton(
              onPressed: () => context.go('/listings/${listing.id}'),
              child: Text('Back to Listing'),
            ),
          ],
        ),
      );
    }

    // Provide EditListingProvider as both concrete type and interface type
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EditListingProvider>(
          create: (_) => EditListingProvider(listing),
        ),
        Provider<ListingFormDataProvider>(
          create: (context) => context.read<EditListingProvider>(),
        ),
      ],
      child: Consumer<EditListingProvider>(
        builder: (context, provider, _) {
          if (provider.successfulUpdate && !_hasNavigatedBack) {
            _hasNavigatedBack = true;
            // Show success and navigate back
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                FeedbackHelpers.showSuccessSnackBar(
                  context,
                  'Listing updated successfully!',
                );
                context.read<ListingDetailProvider>().getListing(listing.id);
                context.read<UserListingsProvider>().refreshListings();
                context.go('/listings/${listing.id}');
              }
            });
          }

          return EditListingForm();
        },
      ),
    );
  }
}
