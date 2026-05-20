import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:provider/provider.dart';

class WardrobeEmptyState extends StatelessWidget {
  const WardrobeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Dresses Yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first dress to start managing your wardrobe and tracking rentals.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final currentRoute = GoRouterState.of(context).uri.path;
                context.read<BackButtonProvider>().pushRoute(currentRoute);
                context.go('/wardrobe/add');
              },
              child: const Text('Add dress'),
            ),
          ],
        ),
      ),
    );
  }
}
