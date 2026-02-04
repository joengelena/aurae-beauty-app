import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/logic/back_button_provider.dart';
import 'package:provider/provider.dart';

class AddServiceButton extends StatelessWidget {
  final int vehicleId;

  const AddServiceButton({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          final currentRoute = GoRouterState.of(context).uri.path;
          context.read<BackButtonProvider>().pushRoute(currentRoute);
          context.go('/garage/$vehicleId/add-service');
        },
        icon: const Icon(Icons.add),
        label: const Text('Service Record'),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
