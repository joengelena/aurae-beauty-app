import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final VoidCallback onToggleWatchlist;

  const ActionBar({
    super.key,
    required this.isSaved,
    required this.onCall,
    required this.onEmail,
    required this.onToggleWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Call
          IconButton(
            icon: const Icon(Icons.phone, size: 28, color: Colors.green),
            onPressed: onCall,
            tooltip: 'Call Seller',
          ),

          // Email
          IconButton(
            icon: const Icon(Icons.email, size: 28, color: Colors.blue),
            onPressed: onEmail,
            tooltip: 'Email Seller',
          ),

          // Watchlist
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 28,
              color: isSaved ? Colors.black : Colors.grey,
            ),
            onPressed: onToggleWatchlist,
            tooltip: isSaved ? 'Remove from Watchlist' : 'Add to Watchlist',
          ),
        ],
      ),
    );
  }
}
