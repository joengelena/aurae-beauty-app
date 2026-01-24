import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddServiceButton extends StatelessWidget {
  final int vehicleId;

  const AddServiceButton({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => context.go('/garage/$vehicleId/add-service'),
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
