import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/data/models/business_settings.dart';
import 'package:shine_app/logic/business_settings_provider.dart';
import 'package:shine_app/logic/profile_provider.dart';
import 'package:shine_app/utils/secure_storage.dart';
import 'package:shine_app/utils/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _step = 0;

  Uint8List? _photoBytes;
  bool _isUploadingPhoto = false;
  bool _photoUploadFailed = false;

  String _selectedDelivery = 'pickup';
  bool _isSaving = false;

  void _advance() {
    if (_step >= 3) return;
    final next = _step + 1;
    setState(() => _step = next);
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    final mimeType = image.mimeType ?? 'image/jpeg';
    // Re-checked after the read: the guard above ran before it, and someone can
    // leave onboarding while a photo is being decoded.
    if (!mounted) return;

    setState(() {
      _photoBytes = bytes;
      _isUploadingPhoto = true;
      _photoUploadFailed = false;
    });

    try {
      await context.read<ProfileProvider>().uploadProfilePhotoOnly(bytes, mimeType);
    } catch (_) {
      if (mounted) setState(() => _photoUploadFailed = true);
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _handleDone(String option) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    _advance(); // go to thanks step immediately
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    await _saveAndRedirect(option);
  }

  Future<void> _saveAndRedirect(String option) async {
    try {
      final userId = await SecureStorage.read('userId') ?? '';
      // _handleDone waits 2.8s before calling this, and the storage read above
      // is async too — comfortably long enough to navigate away first, and
      // context.read on a disposed widget throws.
      if (!mounted) return;
      await context.read<BusinessSettingsProvider>().save(
        BusinessSettings(deliveryOption: option),
        userId,
      );
      if (!mounted) return;
      await context.read<ProfileProvider>().fetchUserProfile(userId);
      // fetchUserProfile → notifyListeners → router sees deliveryOption != null → redirects to /listings
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _skipAll() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await _saveAndRedirect('pickup');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstName =
        context.watch<ProfileProvider>().currentUser?.firstName ?? '';

    return Scaffold(
      backgroundColor: themeBackground,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildWelcomeStep(firstName),
            _buildPhotoStep(),
            _buildDeliveryStep(),
            _buildThanksStep(),
          ],
        ),
      ),
    );
  }

  Widget _stepShell({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: child,
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(String firstName) {
    return _stepShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstName.isNotEmpty ? 'Welcome, $firstName!' : 'Welcome!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Your account is ready. Take a moment to set a few things up, or jump straight in.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: themeTaupe,
                ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _advance,
              child: const Text("Let's set up"),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _isSaving ? null : _skipAll,
              child: _isSaving
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(themeTaupe),
                      ),
                    )
                  : Text(
                      "I'm okay for now",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: themeTaupe,
                            decoration: TextDecoration.underline,
                            decorationColor: themeTaupe,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return _stepShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a profile photo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Help renters put a face to the name.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: themeTaupe,
                ),
          ),
          const SizedBox(height: 40),
          Center(child: _buildAvatarPicker()),
          if (_photoUploadFailed) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Upload failed — tap to retry',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: themeRose),
              ),
            ),
          ],
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploadingPhoto ? null : _advance,
              child: const Text('Next'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _isUploadingPhoto ? null : _advance,
              child: Text(
                'Skip for now',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: themeTaupe,
                      decoration: TextDecoration.underline,
                      decorationColor: themeTaupe,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _pickPhoto,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeAccent.withValues(alpha: 0.18),
              border: Border.all(
                color: _photoBytes != null ? themeAccent : themePrimary,
                width: 2,
              ),
            ),
            child: _photoBytes != null
                ? ClipOval(
                    child: Image.memory(
                      _photoBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: themeTaupe,
                  ),
          ),
          if (_isUploadingPhoto)
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.35),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeText,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryStep() {
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

    return _stepShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you deliver?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Renters see this when browsing your dresses.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: themeTaupe,
                ),
          ),
          const SizedBox(height: 32),
          ...options.map((opt) {
            final selected = _selectedDelivery == opt.value;
            return _buildDeliveryTile(opt, selected);
          }),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _handleDone(_selectedDelivery),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _isSaving ? null : () => _handleDone('pickup'),
              child: Text(
                "I'll decide later",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: themeTaupe,
                      decoration: TextDecoration.underline,
                      decorationColor: themeTaupe,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThanksStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeAccent.withValues(alpha: 0.25),
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 36,
                color: themeAccent,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "You're all set!",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Thanks for setting up. We hope you rent out beautiful moments and make some memories.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: themeTaupe,
                    height: 1.55,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(themeTaupe),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Taking you to Explore...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: themeTaupe,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTile(_DeliveryOption opt, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDelivery = opt.value),
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
                color: selected
                    ? themeAccent.withValues(alpha: 0.35)
                    : themeSurfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                opt.icon,
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
                    opt.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    opt.subtitle,
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
