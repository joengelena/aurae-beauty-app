import 'package:flutter/material.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/logic/watchlist_provider.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isSignedIn) {
        context.read<WatchlistProvider>().fetchWatchlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(message: 'Sign in to view your watchlist.');
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
              style: TextStyle(color: Colors.red),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your watchlist is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Start adding listings to keep track of them',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                context.go('/listings');
              },
              child: Text('Explore listings'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: watchlistProvider.watchlist.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return SizedBox(height: 12);
        }

        final listing = watchlistProvider.watchlist[index - 1];

        return ListingTile(
          listing: listing,
          topRightButton: IconButton(
            onPressed: () async {
              try {
                await watchlistProvider.removeFromWatchlist(listing.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed from watchlist')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to remove from watchlist')),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
          ),
        );
      },
    );
  }
}
