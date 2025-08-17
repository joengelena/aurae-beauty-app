import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundImage: AssetImage('assets/imgs/default_profile.jpg'),
        ),
        const SizedBox(height: 16),
        Text('Jane Doe', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'jane.doe@example.com',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '(+64) 20 1234 5678',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('Edit profile'),
        ),
      ],
    );
  }
}
