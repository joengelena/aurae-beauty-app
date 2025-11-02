import 'package:flutter/material.dart';
import 'package:motorix_app/logic/auth_provider.dart';
import 'package:motorix_app/presentation/widgets/sign_in_to_access.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(message: 'Sign in to view your watchlist.');
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Watchlist Coming Soon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Your saved listings will appear here',
              style: TextStyle(color: Colors.grey[600]),
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
      ),
    );
  }
}
