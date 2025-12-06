import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/presentation/widgets/listing/infinite_grid.dart';
import 'package:motorix_app/presentation/widgets/listing/search_and_filter_bar.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [SearchAndFiltersBar(), Expanded(child: InfiniteGrid())],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => context.go('/listings/post'),
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
