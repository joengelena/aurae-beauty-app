import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/presentation/widgets/common/action_menu_button.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class DressActionMenu extends StatelessWidget {
  final BusinessDress dress;
  final bool redirectAfterDelete;

  const DressActionMenu({
    super.key,
    required this.dress,
    this.redirectAfterDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionMenuButton(
      options: [
        MenuOption(
          icon: Icons.edit,
          title: 'Edit',
          onTap: () => _handleEdit(context),
        ),
        MenuOption(
          icon: Icons.delete,
          title: 'Delete',
          iconColor: themeRed,
          titleColor: themeRed,
          onTap: () => _handleDelete(context),
        ),
      ],
    );
  }

  void _handleEdit(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);
    context.go('/wardrobe/${dress.id}/edit');
  }

  Future<void> _handleDelete(BuildContext context) async {
    final name = dress.internalName ?? '${dress.brand} ${dress.style}';
    final confirmed = await FeedbackHelpers.showDeleteConfirmation(
      context,
      title: 'Delete Dress',
      message:
          'Are you sure you want to delete "$name"? This action cannot be undone.',
    );

    if (!confirmed || !context.mounted) return;

    try {
      await context.read<WardrobeProvider>().deleteDress(dress.id);

      if (context.mounted) {
        FeedbackHelpers.showSuccessSnackBar(context, 'Dress deleted successfully');
        if (redirectAfterDelete) context.go('/wardrobe');
      }
    } catch (e) {
      if (context.mounted) {
        FeedbackHelpers.showErrorSnackBar(
          context,
          'Failed to delete dress: ${e.toString()}',
        );
      }
    }
  }
}
