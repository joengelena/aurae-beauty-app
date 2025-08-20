import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_tile.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:go_router/go_router.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider();
    return FutureBuilder<bool>(
      future: authProvider.isSignedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data == true) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: ListView(
                children: [
                  SizedBox(height: 12),
                  ListingTile(
                    topRightButtom: IconButton(
                      onPressed: () {
                        // handle delete action
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ),
                  ListingTile(
                    topRightButtom: IconButton(
                      onPressed: () {
                        // handle delete action
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: FilledButton(
                      onPressed: () {
                        context.go('/listings');
                      },
                      child: Text('Explore more'),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SignInToAccess(
            message: 'Sign in to view your watchlist.',
          );
        }
      },
    );
  }
}
