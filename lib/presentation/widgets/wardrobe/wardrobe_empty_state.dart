import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_empty_state.dart';
import 'package:provider/provider.dart';

class WardrobeEmptyState extends StatelessWidget {
  const WardrobeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.checkroom_outlined,
      title: 'Your wardrobe is empty',
      body: 'Add your first dress to start tracking your rentals.',
      action: ElevatedButton(
        onPressed: () {
          final currentRoute = GoRouterState.of(context).uri.path;
          context.read<BackButtonProvider>().pushRoute(currentRoute);
          context.go('/wardrobe/add');
        },
        child: const Text('Add dress'),
      ),
    );
  }
}
