import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class WardrobeEmptyState extends StatelessWidget {
  const WardrobeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: themeAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 44,
                color: themeAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your wardrobe is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first dress to start tracking your rentals.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeTaupe,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
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
