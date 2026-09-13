import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final AppDialogType type;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final bool barrierDismissible;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = AppDialogType.info,
    this.primaryButtonText,
    this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.barrierDismissible = true,
  });

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppDialog(
            title: title,
            message: message,
            type: AppDialogType.success,
            primaryButtonText: buttonText ?? 'OK',
            onPrimaryButtonPressed:
                onButtonPressed ?? () => Navigator.pop(dialogContext),
            barrierDismissible: barrierDismissible,
          ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppDialog(
            title: title,
            message: message,
            type: AppDialogType.error,
            primaryButtonText: buttonText ?? 'OK',
            onPrimaryButtonPressed:
                onButtonPressed ?? () => Navigator.pop(dialogContext),
            barrierDismissible: barrierDismissible,
          ),
    );
  }

  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppDialog(
            title: title,
            message: message,
            type: AppDialogType.warning,
            primaryButtonText: buttonText ?? 'OK',
            onPrimaryButtonPressed:
                onButtonPressed ?? () => Navigator.pop(dialogContext),
            barrierDismissible: barrierDismissible,
          ),
    );
  }

  static Future<void> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppDialog(
            title: title,
            message: message,
            type: AppDialogType.warning,
            primaryButtonText: confirmText ?? 'Confirm',
            onPrimaryButtonPressed:
                onConfirm ?? () => Navigator.pop(dialogContext),
            secondaryButtonText: cancelText ?? 'Cancel',
            onSecondaryButtonPressed:
                onCancel ?? () => Navigator.pop(dialogContext),
            barrierDismissible: barrierDismissible,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors();

    return AlertDialog(
      backgroundColor: themeBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // A bare 48px saturated glyph floating above the title was the loudest
      // thing in the dialog. Sitting it in its own tinted disc gives it an
      // edge to belong to, and matches the snackbars.
      icon: Container(
        width: _badgeSize,
        height: _badgeSize,
        decoration: BoxDecoration(
          color: colors.tint,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Icon(_getIconData(), color: colors.ink, size: _badgeIconSize),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        // Taupe rather than full-strength themeText: the title is the thing
        // being said, and this is the sentence explaining it.
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: themeTaupe, height: 1.45),
      ),
      actions: _buildActions(context),
      actionsAlignment: MainAxisAlignment.center,
    );
  }

  /// Badge sized so the icon keeps its old visual weight while gaining a
  /// surface — the glyph shrinks from 48 to 28, the mark as a whole grows.
  static const double _badgeSize = 64;
  static const double _badgeIconSize = 28;

  IconData _getIconData() {
    switch (type) {
      case AppDialogType.success:
        return Icons.check_circle_outline;
      case AppDialogType.error:
        return Icons.error_outline;
      case AppDialogType.warning:
        return Icons.warning_amber_rounded;
      case AppDialogType.info:
        return Icons.info_outline;
    }
  }

  AlertColors _colors() {
    switch (type) {
      case AppDialogType.success:
        return alertSuccess;
      case AppDialogType.error:
        return alertError;
      case AppDialogType.warning:
        return alertWarning;
      case AppDialogType.info:
        return alertInfo;
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    // Add secondary button first (usually cancel/dismiss)
    if (secondaryButtonText != null) {
      actions.add(
        TextButton(
          onPressed: onSecondaryButtonPressed,
          child: Text(secondaryButtonText!),
        ),
      );
    }

    // Add primary button
    if (primaryButtonText != null) {
      actions.add(
        FilledButton(
          onPressed: onPrimaryButtonPressed,
          child: Text(primaryButtonText!),
        ),
      );
    }

    return actions;
  }
}

enum AppDialogType { success, error, warning, info }
