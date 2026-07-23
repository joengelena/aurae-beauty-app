import 'package:flutter/material.dart';
import 'package:shine_app/presentation/widgets/listing/filter_sidebar.dart';
import 'package:shine_app/presentation/widgets/listing/infinite_grid.dart';
import 'package:shine_app/presentation/widgets/listing/filters_and_sort_bar.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  // Matches InfiniteGrid's large-screen breakpoint so the sidebar and the
  // grid's column count switch together.
  static const double _sidebarBreakpoint = 1000;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _sidebarBreakpoint) {
          return const Column(
            children: [
              FiltersAndSortBar(),
              Expanded(child: InfiniteGrid()),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FilterSidebar(),
            Expanded(
              child: Column(
                children: [
                  const FiltersAndSortBar(
                    showFilterBar: false,
                    maxWidth: double.infinity,
                  ),
                  const Expanded(child: InfiniteGrid()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
