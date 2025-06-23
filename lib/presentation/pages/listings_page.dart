import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing/infinite_grid.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.center, child: InfiniteGrid());
  }
}
