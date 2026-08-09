import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/logic/active_profile_provider.dart';
import 'package:shine_app/presentation/widgets/common/loading_button.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';

/// Owner-only: generate a single-use invite code to hand out. Deliberately
/// minimal — no list of past invites or revoke action yet (that's a later
/// pass, once a fuller owner-side member-management screen is built).
class InviteTeamMemberPage extends StatefulWidget {
  const InviteTeamMemberPage({super.key});

  @override
  State<InviteTeamMemberPage> createState() => _InviteTeamMemberPageState();
}

class _InviteTeamMemberPageState extends State<InviteTeamMemberPage> {
  String _selectedRole = 'staff';
  String? _generatedCode;
  bool _isGenerating = false;

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);

    try {
      final code = await context.read<ActiveProfileProvider>().generateInviteCode(
            _selectedRole,
          );
      if (!mounted) return;
      setState(() => _generatedCode = code);
    } on AppException catch (e) {
      if (!mounted) return;
      FeedbackHelpers.showErrorSnackBar(context, e.message);
    } catch (e) {
      if (!mounted) return;
      FeedbackHelpers.showErrorSnackBar(context, 'Failed to create invite.');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _handleCopy() {
    final code = _generatedCode;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    FeedbackHelpers.showInfoSnackBar(context, 'Code copied');
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<ActiveProfileProvider>().role;

    if (role != 'owner') {
      return Center(
        child: Text(
          'Only the business owner can invite team members.',
          style: TextStyle(color: themeTaupe),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite a team member',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Generate a code and share it with them — it expires in 7 days and works once.',
              style: TextStyle(color: themeTaupe, fontSize: 14),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            if (_generatedCode == null) ...[
              Row(
                children: [
                  Expanded(
                    child: _RoleChip(
                      label: 'Staff',
                      selected: _selectedRole == 'staff',
                      onTap: () => setState(() => _selectedRole = 'staff'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: _RoleChip(
                      label: 'Co-owner',
                      selected: _selectedRole == 'owner',
                      onTap: () => setState(() => _selectedRole = 'owner'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  label: 'Generate code',
                  isLoading: _isGenerating,
                  onPressed: _handleGenerate,
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: themeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _generatedCode!,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    TextButton.icon(
                      onPressed: _handleCopy,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy code'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  label: 'Generate another code',
                  isOutlined: true,
                  onPressed: () => setState(() => _generatedCode = null),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? themeAccent.withValues(alpha: 0.35) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? themeAccentInk : const Color(0xFFEADFD8),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? themeAccentInk : themeText,
          ),
        ),
      ),
    );
  }
}
