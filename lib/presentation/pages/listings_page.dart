import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/presentation/widgets/listing/infinite_grid.dart';
import 'package:shine_app/presentation/widgets/listing/filters_and_sort_bar.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FiltersAndSortBar(),
        Expanded(child: InfiniteGrid()),
      ],
    );
  }
}
