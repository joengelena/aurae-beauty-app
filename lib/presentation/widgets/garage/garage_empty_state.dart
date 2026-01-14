import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:provider/provider.dart';

class GarageEmptyState extends StatelessWidget {
  const GarageEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Vehicles Yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first vehicle to start tracking WOF, registration, and service dates',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                // Push current route onto stack for back button
                final currentRoute = GoRouterState.of(context).uri.path;
                context.read<BackButtonProvider>().pushRoute(currentRoute);

                context.go('/garage/add');
              },
              child: const Text('Add vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
