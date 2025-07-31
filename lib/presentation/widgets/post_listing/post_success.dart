import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:provider/provider.dart';

class PostSuccess extends StatelessWidget {
  const PostSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PostListingProvider>();

    return Center(
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade800, width: 6),
            ),
            child: Center(
              child: Icon(Icons.check, size: 64, color: Colors.green.shade800),
            ),
          ),

          Text(
            'Upload successful',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          OutlinedButton(
            onPressed: () {
              context.go('/listings/${provider.newListingId}');
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('View listing'),
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
            child: Text('Home'),
          ),
        ],
      ),
    );
  }
}
