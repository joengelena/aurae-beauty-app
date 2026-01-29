import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:motorix_app/logic/post_listing_provider.dart';
import 'package:motorix_app/logic/profile_provider.dart';
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
            // Push current route onto stack for back button
            final currentRoute = GoRouterState.of(context).uri.path;
            context.read<BackButtonProvider>().pushRoute(currentRoute);

            final postListingProvider = context.read<PostListingProvider>();
            final profileProvider = context.read<ProfileProvider>();

            postListingProvider.resetProvider();
            postListingProvider.setDefaultLocation(profileProvider.currentUser?.location);

            context.go('/listings/post');
          },
        ),
      ],
    );
  }
}
