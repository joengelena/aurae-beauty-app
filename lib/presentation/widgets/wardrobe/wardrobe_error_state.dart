import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

class WardrobeErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const WardrobeErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: themeRose.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 32, color: themeRose),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load wardrobe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeTaupe,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
