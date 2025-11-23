import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/edit_listing_provider.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/presentation/widgets/edit_listing/edit_listing_form.dart';
import 'package:motorix_app/logic/listing_form_data_provider.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:motorix_app/utils/secure_storage.dart';
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
      return SignInToAccess(message: 'Sign in to edit your listing');
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Listing updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the listing detail and navigate back
                context.read<ListingDetailProvider>().getListing(listing.id);
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
