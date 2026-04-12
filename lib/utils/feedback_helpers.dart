import 'package:flutter/material.dart';
import 'package:shine_app/presentation/widgets/common/app_dialog.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';

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
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: themeGreen,
        behavior: SnackBarBehavior.floating,
        duration: AppConstants.snackBarDurationSeconds,
        width: AppConstants.contentMaxWidth,
      ),
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: themeRed,
        behavior: SnackBarBehavior.floating,
        duration: AppConstants.snackBarDurationSeconds,
        width: AppConstants.contentMaxWidth,
      ),
    );
  }

  /// Shows a success snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: themeBlue,
        behavior: SnackBarBehavior.floating,
        duration: AppConstants.snackBarDurationSeconds,
        width: AppConstants.contentMaxWidth,
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
