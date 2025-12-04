import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool isOutlined;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildContent(context),
      );
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!isLoading) {
      return Text(label);
    }

    final Color spinnerColor = isOutlined
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
      ),
    );
  }
}
