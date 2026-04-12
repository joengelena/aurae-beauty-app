import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/back_button_provider.dart';
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
              kIsWeb ? Icons.phone_android : Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              kIsWeb ? 'Mobile App Only Feature' : 'No Vehicles Yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb
                  ? 'Adding vehicles and scheduling service reminders is only available on the Aurae mobile app. Download the app to track WOF, registration, insurance, and service dates with automatic notifications.'
                  : 'Add your first vehicle to start tracking WOF, registration, and service dates',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!kIsWeb) ...[
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
          ],
        ),
      ),
    );
  }
}
