import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/infinite_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.center, child: InfiniteGrid());
  }
}
