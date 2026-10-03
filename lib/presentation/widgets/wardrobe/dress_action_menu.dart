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
    final isSold = dress.status == 'sold';

    return ActionMenuButton(
      options: [
        MenuOption(
          icon: Icons.edit,
          title: 'Edit',
          onTap: () => _handleEdit(context),
        ),
        if (isSold)
          MenuOption(
            icon: Icons.replay,
            title: 'Reactivate',
            onTap: () => _handleReactivate(context),
          )
        else
          MenuOption(
            icon: Icons.sell_outlined,
            title: 'Mark as sold',
            onTap: () => _handleMarkAsSold(context),
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

  /// A context that outlives this menu, for feedback after an await.
  ///
  /// Marking sold, reactivating or deleting refreshes the wardrobe, which moves
  /// or removes the card this menu sits on — so by the time the request
  /// returns, the menu's own context is unmounted and a `context.mounted`
  /// check silently swallows the snackbar. The root navigator sits below the
  /// app's ScaffoldMessenger and lives as long as the app, so feedback shown
  /// through it always lands.
  static BuildContext _feedbackContext(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).context;

  Future<void> _handleMarkAsSold(BuildContext context) async {
    final name = dress.internalName ?? '${dress.brand} ${dress.style}';
    final feedbackContext = _feedbackContext(context);
    final confirmed = await FeedbackHelpers.showConfirmation(
      context,
      title: 'Mark as Sold',
      message:
          'Mark "$name" as sold? It will move to your Sold section and disappear from Browse, but its rental history stays intact.',
      confirmButtonText: 'Mark as Sold',
    );

    if (!confirmed || !context.mounted) return;

    try {
      await context.read<WardrobeProvider>().markAsSold(dress.id);

      if (feedbackContext.mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          feedbackContext,
          '"$name" marked as sold',
        );
      }
    } catch (e) {
      if (feedbackContext.mounted) {
        FeedbackHelpers.showErrorSnackBar(
          feedbackContext,
          userMessage(e, fallback: 'Could not mark this dress as sold. Please try again.'),
        );
      }
    }
  }

  Future<void> _handleReactivate(BuildContext context) async {
    final name = dress.internalName ?? '${dress.brand} ${dress.style}';
    final feedbackContext = _feedbackContext(context);

    try {
      await context.read<WardrobeProvider>().reactivate(dress.id);

      if (feedbackContext.mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          feedbackContext,
          '"$name" reactivated',
        );
      }
    } catch (e) {
      if (feedbackContext.mounted) {
        FeedbackHelpers.showErrorSnackBar(
          feedbackContext,
          userMessage(e, fallback: 'Could not reactivate this dress. Please try again.'),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final name = dress.internalName ?? '${dress.brand} ${dress.style}';
    final feedbackContext = _feedbackContext(context);
    final confirmed = await FeedbackHelpers.showDeleteConfirmation(
      context,
      title: 'Delete Dress',
      message:
          'Are you sure you want to delete "$name"? This action cannot be undone.',
    );

    if (!confirmed || !context.mounted) return;

    try {
      await context.read<WardrobeProvider>().deleteDress(dress.id);

      if (feedbackContext.mounted) {
        FeedbackHelpers.showSuccessSnackBar(
          feedbackContext,
          'Dress deleted successfully',
        );
        if (redirectAfterDelete) feedbackContext.go('/wardrobe');
      }
    } catch (e) {
      if (feedbackContext.mounted) {
        FeedbackHelpers.showErrorSnackBar(
          feedbackContext,
          userMessage(e, fallback: 'Could not delete this dress. Please try again.'),
        );
      }
    }
  }
}
