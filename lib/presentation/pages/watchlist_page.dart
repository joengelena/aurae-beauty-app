import 'package:flutter/material.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/watchlist_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_empty_state.dart';
import 'package:shine_app/presentation/widgets/sign_in_to_access.dart';
import 'package:shine_app/presentation/widgets/listing/listing_tile.dart';
import 'package:shine_app/presentation/widgets/listing/watchlist_heart_button.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(
        icon: Icons.favorite_border,
        title: 'Your watchlist',
        subtitle: 'Sign in to save dresses you love and revisit them anytime.',
      );
    }

    final watchlistProvider = context.watch<WatchlistProvider>();

    if (watchlistProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (watchlistProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              watchlistProvider.errorMessage!,
              style: TextStyle(color: themeRose),
            ),
            SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                watchlistProvider.fetchWatchlist();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (watchlistProvider.watchlist.isEmpty) {
      return AppEmptyState(
        icon: Icons.favorite_border,
        title: 'No favourites yet',
        body: 'Save dresses you love to find them here.',
        action: ElevatedButton(
          onPressed: () => context.go('/listings'),
          child: const Text('Explore dresses'),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: () => watchlistProvider.fetchWatchlist(),
          child: ListView.builder(
            itemCount: watchlistProvider.watchlist.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(height: 12);
              }

              final listing = watchlistProvider.watchlist[index - 1];

              return ListingTile(
                listing: listing,
                topRightButton: WatchlistHeartButton(
                  isSaved: true,
                  onPressed: () async {
                    try {
                      await watchlistProvider.removeFromWatchlist(listing.id);
                      if (context.mounted) {
                        FeedbackHelpers.showSuccessSnackBar(
                          context,
                          'Removed from watchlist',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        FeedbackHelpers.showErrorSnackBar(
                          context,
                          'Failed to remove from watchlist',
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
