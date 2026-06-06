import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/post_listing_provider.dart';
import 'package:shine_app/logic/profile_provider.dart';
import 'package:shine_app/logic/user_listings_provider.dart';
import 'package:shine_app/presentation/widgets/common/action_menu_button.dart';
import 'package:shine_app/presentation/widgets/common/labeled_fab.dart';
import 'package:shine_app/presentation/widgets/listing/listing_tile.dart';
import 'package:shine_app/presentation/widgets/profile/user_profile.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Fetch user listings when profile page is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserListingsProvider>().refreshListings();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final provider = context.read<UserListingsProvider>();
    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

    if (isNearBottom && provider.canLoadMore && !provider.isLoading) {
      provider.loadMoreListings();
    }
  }

  Future<void> _handleStatusChange({
    required int listingId,
    required Future<void> Function(int) onStatusChange,
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      await onStatusChange(listingId);
      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(context, successMessage);
      }
    } catch (e) {
      if (mounted) {
        FeedbackHelpers.showErrorSnackBar(context, errorMessage);
      }
    }
  }

  Future<void> _handleDeleteListing(int listingId) async {
    final confirmed = await FeedbackHelpers.showDeleteConfirmation(
      context,
      title: 'Delete Listing',
      message:
          'Are you sure you want to delete this listing? This action cannot be undone.',
    );

    if (!confirmed || !mounted) return;

    final userListingsProvider = context.read<UserListingsProvider>();

    try {
      await userListingsProvider.deleteListing(listingId);

      if (mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          context,
          'Listing deleted successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage =
            e is AppException
                ? e.message
                : 'Failed to delete listing. Please try again.';
        FeedbackHelpers.showErrorSnackBar(context, errorMessage);
      }
    }
  }

  List<MenuOption> _buildMenuOptions(Listing listing) {
    final userListingsProvider = context.read<UserListingsProvider>();
    final options = <MenuOption>[
      MenuOption(
        icon: Icons.edit,
        title: 'Edit',
        onTap: () {
          // Push current route onto stack for back button
          final currentRoute = GoRouterState.of(context).uri.path;
          context.read<BackButtonProvider>().pushRoute(currentRoute);

          context.go('/listings/${listing.id}/edit');
        },
      ),
    ];

    if (listing.status == 'active') {
      options.add(
        MenuOption(
          icon: Icons.check_circle,
          title: 'Mark as Sold',
          onTap:
              () => _handleStatusChange(
                listingId: listing.id,
                onStatusChange: userListingsProvider.markAsSold,
                successMessage: 'Listing marked as sold',
                errorMessage: 'Failed to mark listing as sold',
              ),
        ),
      );
    } else if (listing.status == 'sold') {
      options.add(
        MenuOption(
          icon: Icons.autorenew,
          title: 'Mark as Active',
          onTap:
              () => _handleStatusChange(
                listingId: listing.id,
                onStatusChange: userListingsProvider.markAsActive,
                successMessage: 'Listing marked as active',
                errorMessage: 'Failed to mark listing as active',
              ),
        ),
      );
    }

    options.add(
      MenuOption(
        icon: Icons.delete,
        title: 'Delete',
        iconColor: themeRed,
        titleColor: themeRed,
        onTap: () => _handleDeleteListing(listing.id),
      ),
    );

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final userListingsProvider = context.watch<UserListingsProvider>();

    return Stack(
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () => userListingsProvider.refreshListings(),
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 24),
                  UserProfile(),
                  SizedBox(height: 24),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 32,
                    endIndent: 32,
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          'My Listings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      // Loading state
                      if (userListingsProvider.isLoading &&
                          userListingsProvider.userListings.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      // Error state
                      if (userListingsProvider.errorMessage.isNotEmpty &&
                          userListingsProvider.userListings.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: themeRed,
                              ),
                              SizedBox(height: 16),
                              Text(
                                userListingsProvider.errorMessage,
                                style: TextStyle(color: themeRed),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      // Empty state
                      if (!userListingsProvider.isLoading &&
                          userListingsProvider.userListings.isEmpty &&
                          userListingsProvider.errorMessage.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No listings yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your dress listings will appear here',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      // Listings
                      ...userListingsProvider.userListings.map((listing) {
                        return ListingTile(
                          listing: listing,
                          topRightButton: ActionMenuButton(
                            options: _buildMenuOptions(listing),
                          ),
                        );
                      }),
                      // Loading more indicator
                      if (userListingsProvider.isLoading &&
                          userListingsProvider.userListings.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        LabeledFab(
          label: 'Post',
          onPressed: () {
            // Push current route onto stack for back button
            final currentRoute = GoRouterState.of(context).uri.path;
            context.read<BackButtonProvider>().pushRoute(currentRoute);

            final postListingProvider = context.read<PostListingProvider>();
            final profileProvider = context.read<ProfileProvider>();

            postListingProvider.resetProvider();
            postListingProvider.setDefaultLocation(profileProvider.currentUser?.location);

            context.go('/listings/post');
          },
        ),
      ],
    );
  }
}
