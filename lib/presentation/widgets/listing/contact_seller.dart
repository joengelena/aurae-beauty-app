import 'package:flutter/material.dart';

class ContactSeller extends StatelessWidget {
  const ContactSeller({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade50,
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            const CircleAvatar(
              radius: 44,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 16),

            // Name
            Text('Jane Doe', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),

            // Contact Seller Title + Icons
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Text(
                    'Contact Seller',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.phone,
                      size: 28,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      // Add call logic
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.email, size: 28, color: Colors.blue),
                    onPressed: () {
                      // Add email logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
