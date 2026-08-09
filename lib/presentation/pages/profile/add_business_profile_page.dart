import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/presentation/widgets/profile/settings_row.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';

/// Entry point for turning a Customer-only account into a business Owner or
/// Staff profile — the two ways of "adding a profile" per the multi-profile
/// design (see FEATURES.md).
class AddBusinessProfilePage extends StatelessWidget {
  const AddBusinessProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a business profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Own a boutique, or joining one as staff? Pick one below.',
              style: TextStyle(color: themeTaupe, fontSize: 14),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            SettingsRow(
              icon: Icons.storefront_outlined,
              label: 'I own a boutique',
              onTap: () => context.push('/profile/add-business/create'),
            ),
            SettingsRow(
              icon: Icons.qr_code_2_rounded,
              label: 'I have an invite code',
              onTap: () => context.push('/profile/add-business/join'),
            ),
          ],
        ),
      ),
    );
  }
}
