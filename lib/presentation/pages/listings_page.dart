import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing/infinite_grid.dart';
import 'package:motorix_app/presentation/widgets/listing/search_and_filter_bar.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [SearchAndFiltersBar(), Expanded(child: InfiniteGrid())],
    );
  }
}
