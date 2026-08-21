import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/logic/active_profile_provider.dart';
import 'package:shine_app/presentation/widgets/common/loading_button.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';

class CreateBusinessPage extends StatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  State<CreateBusinessPage> createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends State<CreateBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<ActiveProfileProvider>().createBusiness(
            _nameController.text.trim(),
          );
      if (!mounted) return;
      FeedbackHelpers.showSuccessSnackBar(context, 'Business created');
      context.go('/profile');
    } on AppException catch (e) {
      if (!mounted) return;
      FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (!mounted) return;
      FeedbackHelpers.showErrorSnackBar(context, 'Failed to create business.');
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
                'Create your business',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                "What's your boutique called? You can change this later.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: themeTaupe),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Business name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  return null;
                },
                onFieldSubmitted: (_) => _handleCreate(),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  label: 'Create business',
                  isLoading: _isSaving,
                  onPressed: _handleCreate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
