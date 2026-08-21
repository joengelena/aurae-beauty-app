import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/business_settings_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_card.dart';
import 'package:shine_app/presentation/widgets/profile/settings_row.dart';
import 'package:shine_app/utils/secure_storage.dart';
import 'package:shine_app/utils/theme.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessSettingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessSettingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            _buildSection(
              label: 'Account',
              description: 'Manage your profile and login credentials.',
              child: _buildAccountOptions(context),
            ),
            _buildSection(
              label: 'Delivery Options',
              description: 'Let renters know how they can receive dresses.',
              child: _buildDeliverySelector(context, provider),
            ),
            _buildSection(
              label: 'Rental Settings',
              description:
                  'Days every dress stays unavailable after a rental ends, for cleaning. Applies to all your dresses.',
              child: _buildCleaningBufferSelector(context, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCleaningBufferSelector(
    BuildContext context,
    BusinessSettingsProvider provider,
  ) {
    final days = provider.settings.cleaningBufferDays;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Cleaning buffer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed:
                (provider.isSaving || days <= 1)
                    ? null
                    : () => _updateCleaningBuffer(context, provider, days - 1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$days',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed:
                provider.isSaving
                    ? null
                    : () => _updateCleaningBuffer(context, provider, days + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCleaningBuffer(
    BuildContext context,
    BusinessSettingsProvider provider,
    int days,
  ) async {
    if (days < 1) return;
    final updated = provider.settings.copyWith(cleaningBufferDays: days);
    final userId = await SecureStorage.read('userId') ?? '';
    final ok = await provider.save(updated, userId);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : 'Failed to save settings',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildAccountOptions(BuildContext context) {
    final items = [
      (Icons.lock_outline, 'Change password', '/profile/change-password'),
    ];

    return Column(
      children:
          items.map((item) {
            final (icon, label, route) = item;
            return SettingsRow(
              icon: icon,
              label: label,
              onTap: () => context.push(route),
            );
          }).toList(),
    );
  }

  Widget _buildSection({
    required String label,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: themeTaupe,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        child,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDeliverySelector(
    BuildContext context,
    BusinessSettingsProvider provider,
  ) {
    final options = [
      _DeliveryOption(
        value: 'pickup',
        label: 'Pickup only',
        icon: Icons.store_outlined,
        subtitle: 'Renter collects in person',
      ),
      _DeliveryOption(
        value: 'postal',
        label: 'Postal only',
        icon: Icons.local_shipping_outlined,
        subtitle: 'You ship to the renter',
      ),
      _DeliveryOption(
        value: 'both',
        label: 'Both',
        icon: Icons.swap_horiz_outlined,
        subtitle: 'Renter can choose',
      ),
    ];

    return Column(
      children:
          options.map((opt) {
            final selected = provider.settings.deliveryOption == opt.value;
            return _DeliveryTile(
              option: opt,
              selected: selected,
              saving: provider.isSaving,
              onTap: () => _selectDelivery(context, provider, opt.value),
            );
          }).toList(),
    );
  }

  Future<void> _selectDelivery(
    BuildContext context,
    BusinessSettingsProvider provider,
    String value,
  ) async {
    if (provider.isSaving || provider.settings.deliveryOption == value) return;
    final updated = provider.settings.copyWith(deliveryOption: value);
    final userId = await SecureStorage.read('userId') ?? '';
    final ok = await provider.save(updated, userId);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : 'Failed to save settings',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _DeliveryOption {
  final String value;
  final String label;
  final IconData icon;
  final String subtitle;

  const _DeliveryOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.subtitle,
  });
}

class _DeliveryTile extends StatelessWidget {
  final _DeliveryOption option;
  final bool selected;
  final bool saving;
  final VoidCallback onTap;

  const _DeliveryTile({
    required this.option,
    required this.selected,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? themeAccent.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? themeAccent : themePrimary,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    selected
                        ? themeAccent.withValues(alpha: 0.35)
                        : themeSurfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                size: 20,
                color: selected ? themeText : themeTaupe,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: themeAccent, size: 20)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: themeBorderMuted,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
