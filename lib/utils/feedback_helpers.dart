import 'package:flutter/material.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/presentation/widgets/common/app_dialog.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';

// userMessage lives with the exceptions it reads, but it is reached for
// alongside the snackbars below, so it stays importable from here too.
export 'package:shine_app/data/exceptions/app_exception.dart' show userMessage;

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

  /// Shows a generic warning confirmation dialog with a custom primary button label
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmButtonText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AppDialog(
          title: title,
          message: message,
          type: AppDialogType.warning,
          primaryButtonText: confirmButtonText,
          onPrimaryButtonPressed: () => Navigator.pop(dialogContext, true),
          secondaryButtonText: 'Back',
          onSecondaryButtonPressed: () => Navigator.pop(dialogContext, false),
          barrierDismissible: false,
        );
      },
    );
    return result ?? false;
  }

  /// The one place a snackbar is built.
  ///
  /// Everything visible about an alert is decided here so the three public
  /// wrappers below stay one line each and cannot drift apart.
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required AlertColors colors,
    required IconData icon,
    required Duration duration,
    required bool dismissible,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Snackbars queue by default, so a screen that reports two failures makes
    // the person sit through the first before seeing the second. The newest
    // message is the one worth reading.
    messenger.hideCurrentSnackBar();

    // contentMaxWidth is a cap, not a width. Handing SnackBar a width wider
    // than the screen is how a floating bar ends up cut off on a phone.
    final available =
        MediaQuery.sizeOf(context).width - (AppConstants.snackBarSideGutter * 2);
    final width =
        available < AppConstants.contentMaxWidth
            ? available
            : AppConstants.contentMaxWidth;

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colour is the whole signal in the old design, which leaves out
            // anyone who cannot separate rose from peach. The icon says which
            // kind of message this is without relying on that.
            Icon(icon, color: colors.ink, size: 20),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: themeText,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.tint,
        // The tint is close enough to themeBackground that the bar loses its
        // shape against the page without an edge.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        elevation: 2,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        width: width,
        showCloseIcon: dismissible,
        closeIconColor: colors.ink,
      ),
    );
  }

  /// Confirms something worked. Quiet and brief — it needs noticing, not reading.
  static void showSuccessSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      colors: alertSuccess,
      icon: Icons.check_circle_outline,
      duration: AppConstants.snackBarDurationSeconds,
      dismissible: false,
    );
  }

  /// Reports a failure. Stays longer and can be dismissed, because it carries
  /// a sentence the person is meant to act on rather than an acknowledgement.
  static void showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      colors: alertError,
      icon: Icons.error_outline,
      duration: AppConstants.snackBarErrorDuration,
      dismissible: true,
    );
  }

  /// Neutral notice — nothing went wrong and nothing was achieved.
  static void showInfoSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      colors: alertInfo,
      icon: Icons.info_outline,
      duration: AppConstants.snackBarDurationSeconds,
      dismissible: false,
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
          errorMessage ??
              userMessage(e, fallback: 'Could not delete $itemName. Please try again.'),
        );
      }
    }
  }
}
