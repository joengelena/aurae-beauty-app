import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing/watchlist_preview.dart';
import 'package:go_router/go_router.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        WatchlistPreview(),
        WatchlistPreview(),
        Align(
          alignment: Alignment.center,
          child: FilledButton(
            onPressed: () {
              context.go('/listings');
            },
            child: Text('Explore more'),
          ),
        ),
      ],
    );
  }
}
