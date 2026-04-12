import 'package:flutter/material.dart';
import 'package:shine_app/presentation/widgets/profile/email_verification_expired.dart';
import 'package:shine_app/presentation/widgets/profile/email_verification_success.dart';

class EmailVerificationPage extends StatelessWidget {
  final String? errorCode;

  const EmailVerificationPage({super.key, this.errorCode});

  bool get _isLinkExpired => errorCode != null;

  @override
  Widget build(BuildContext context) {
    return _isLinkExpired
        ? const EmailVerificationExpired()
        : const EmailVerificationSuccess();
  }
}
