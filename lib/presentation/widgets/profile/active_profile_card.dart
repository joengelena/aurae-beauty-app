import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/active_profile_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_card.dart';
import 'package:shine_app/utils/theme.dart';

/// Shows which context the account is currently browsing as — Customer, or
/// its business (Owner/Staff) — with a single tap target to switch, or to
/// add a business profile if there isn't one yet.
class ActiveProfileCard extends StatelessWidget {
  const ActiveProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveProfileProvider>();

    if (provider.isLoading) {
      return const _CardShell(
        highlighted: false,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (provider.hasError) {
      return _CardShell(
        highlighted: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                provider.errorMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: provider.loadMyBusiness,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final String heading;
    final String subtitle;
    final String buttonLabel;
    final VoidCallback onPressed;

    if (!provider.hasBusiness) {
      heading = "You're browsing as a Customer";
      subtitle = 'Own a boutique? Add a business profile.';
      buttonLabel = 'Add a business profile';
      onPressed = () => context.push('/profile/add-business');
    } else if (!provider.isBusinessActive) {
      heading = "You're browsing as a Customer";
      subtitle = 'Switch to ${provider.business!.name} (${_roleLabel(provider.role)})';
      buttonLabel = 'Switch';
      onPressed = () => provider.setActiveProfile(true);
    } else {
      heading = "You're managing ${provider.business!.name}";
      subtitle = _roleLabel(provider.role);
      buttonLabel = 'Switch to Customer';
      onPressed = () => provider.setActiveProfile(false);
    }

    return _CardShell(
      highlighted: provider.isBusinessActive,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String? role) {
    return switch (role) {
      'owner' => 'Owner',
      'staff' => 'Staff',
      _ => '',
    };
  }
}

class _CardShell extends StatelessWidget {
  final bool highlighted;
  final Widget child;

  const _CardShell({required this.highlighted, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: highlighted ? themeAccent.withValues(alpha: 0.15) : Colors.white,
      child: child,
    );
  }
}
