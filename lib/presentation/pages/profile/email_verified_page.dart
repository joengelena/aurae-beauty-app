import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/utils/theme.dart';

class EmailVerifiedPage extends StatelessWidget {
  const EmailVerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green check icon inside a circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: themeGreen, width: 6),
            ),
            child: Center(
              child: Icon(Icons.check, size: 64, color: themeGreen),
            ),
          ),

          Text('Email verified', style: Theme.of(context).textTheme.titleLarge),

          Text(
            'Email has been successfully verified',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          OutlinedButton(
            onPressed: () {
              context.go('/listings');
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Explore listings'),
          ),
        ],
      ),
    );
  }
}
