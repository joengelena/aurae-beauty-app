import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/common/app_dialog.dart';

/// Helper class for user feedback operations like confirmation dialogs and snackbars
class FeedbackHelpers {
  /// Shows a delete confirmation dialog
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AppDialog(
          title: title,
          message: message,
          type: AppDialogType.warning,
          primaryButtonText: 'Delete',
          onPrimaryButtonPressed: () => Navigator.pop(dialogContext, true),
          secondaryButtonText: 'Cancel',
          onSecondaryButtonPressed: () => Navigator.pop(dialogContext, false),
          barrierDismissible: false,
        );
      },
    );
    return result ?? false;
  }

  /// Shows a success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Handles a delete operation with confirmation, execution, and feedback
  static Future<void> handleDelete(
    BuildContext context, {
    required String itemName,
    required Future<void> Function() onDelete,
    String? successMessage,
    String? errorMessage,
  }) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete $itemName',
      message:
          'Are you sure you want to delete this $itemName? This action cannot be undone.',
    );

    if (!confirmed || !context.mounted) return;

    try {
      await onDelete();

      if (context.mounted) {
        showSuccessSnackBar(
          context,
          successMessage ?? '$itemName deleted successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          errorMessage ?? 'Failed to delete $itemName: ${e.toString()}',
        );
      }
    }
  }
}
