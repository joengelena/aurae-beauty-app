import 'package:flutter/material.dart';
import 'package:shine_app/utils/constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: March 3, 2026',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Text(
                  'Information We Collect',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Account information (email, name, phone number)\n'
                  '• Location data (for local marketplace results)\n'
                  '• Vehicle information (make, model, service history)\n'
                  '• Photos (vehicle images you upload)',
                ),
                const SizedBox(height: 24),
                Text(
                  'How We Use Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Provide marketplace and garage management services\n'
                  '• Send reminders for vehicle document renewals\n'
                  '• Improve app functionality',
                ),
                const SizedBox(height: 24),
                Text(
                  'Data Security',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your data is encrypted and securely stored. We never sell your personal information.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Contact Us',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('support@aurae.com'),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
