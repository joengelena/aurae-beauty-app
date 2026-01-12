import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/infinite_grid.dart';
import 'package:motorix_app/presentation/widgets/listing/filters_and_sort_bar.dart';
import 'package:motorix_app/presentation/widgets/common/labeled_fab.dart';
import 'package:provider/provider.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const FiltersAndSortBar(),
            const Expanded(child: InfiniteGrid()),
          ],
        ),
        LabeledFab(
          label: 'Post',
          onPressed: () {
            context.read<PostListingProvider>().resetProvider();
            context.go('/listings/post');
          },
        ),
      ],
    );
  }
}
