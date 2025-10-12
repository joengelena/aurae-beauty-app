import 'package:flutter/material.dart';

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
            onPrimaryButtonPressed: onConfirm ?? () => Navigator.pop(dialogContext),
            secondaryButtonText: cancelText ?? 'Cancel',
            onSecondaryButtonPressed: onCancel ?? () => Navigator.pop(dialogContext),
            barrierDismissible: barrierDismissible,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData();
    final iconColor = _getIconColor();

    return AlertDialog(
      icon: Icon(iconData, color: iconColor, size: 48),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: _buildActions(context),
      actionsAlignment: MainAxisAlignment.center,
    );
  }

  IconData _getIconData() {
    switch (type) {
      case AppDialogType.success:
        return Icons.check_circle;
      case AppDialogType.error:
        return Icons.error;
      case AppDialogType.warning:
        return Icons.warning;
      case AppDialogType.info:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AppDialogType.success:
        return Colors.green;
      case AppDialogType.error:
        return Colors.red;
      case AppDialogType.warning:
        return Colors.orange;
      case AppDialogType.info:
        return Colors.blue;
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
