import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/data/models/listing.dart';
import 'package:motorix_app/logic/user_listings_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_tile.dart';
import 'package:motorix_app/presentation/widgets/profile/user_profile.dart';
import 'package:motorix_app/utils/secure_storage.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserListings();
    });
    _scrollController.addListener(_onScroll);
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

  Future<void> _initializeUserListings() async {
    if (_hasInitialized || !mounted) return;
    _hasInitialized = true;

    try {
      final userId = await SecureStorage.read('userId');
      if (userId != null && userId.isNotEmpty && mounted) {
        final provider = context.read<UserListingsProvider>();
        await provider.fetchUserListings(userId);
      }
    } catch (e) {
      debugPrint('Error initializing user listings: $e');
    }
  }

  void showlistingBottomSheet(BuildContext context, Listing listing) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Options', style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text(
                  'Edit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/listings/${listing.id}/edit');
                },
              ),
              if (listing.status == 'active')
                ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text(
                    'Mark as Sold',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final userListingsProvider =
                        context.read<UserListingsProvider>();
                    try {
                      await userListingsProvider.markAsSold(listing.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Listing marked as sold'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to mark listing as sold'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text(
                  'Delete',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement delete functionality
                  debugPrint('Delete listing ${listing.id}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userListingsProvider = context.watch<UserListingsProvider>();

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: () async {
            final userId = await SecureStorage.read('userId');
            if (userId != null && userId.isNotEmpty) {
              await userListingsProvider.fetchUserListings(userId);
            }
          },
          child: ListView(
            controller: _scrollController,
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
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            userListingsProvider.errorMessage,
                            style: TextStyle(color: Colors.red),
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
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No listings yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your vehicle listings will appear here',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  // Listings
                  ...userListingsProvider.userListings.map((listing) {
                    return ListingTile(
                      listing: listing,
                      topRightButton: IconButton(
                        onPressed: () {
                          showlistingBottomSheet(context, listing);
                        },
                        icon: const Icon(Icons.more_vert),
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
            ],
          ),
        ),
      ),
    );
  }
}
