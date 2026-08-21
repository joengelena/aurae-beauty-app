import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/logic/active_profile_provider.dart';
import 'package:shine_app/presentation/widgets/common/loading_button.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';

class JoinBusinessPage extends StatefulWidget {
  const JoinBusinessPage({super.key});

  @override
  State<JoinBusinessPage> createState() => _JoinBusinessPageState();
}

class _JoinBusinessPageState extends State<JoinBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<ActiveProfileProvider>().redeemInviteCode(
            _codeController.text.trim(),
          );
      if (!mounted) return;
      FeedbackHelpers.showSuccessSnackBar(context, 'You joined the business');
      context.go('/profile');
    } on AppException catch (e) {
      if (!mounted) return;
      FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (!mounted) return;
      FeedbackHelpers.showErrorSnackBar(context, 'Failed to join business.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join with a code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'Enter the invite code the business owner shared with you.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: themeTaupe),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              TextFormField(
                controller: _codeController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  UpperCaseTextFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Invite code',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  return null;
                },
                onFieldSubmitted: (_) => _handleJoin(),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  label: 'Join business',
                  isLoading: _isSaving,
                  onPressed: _handleJoin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
