import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/widgets/common/password_field.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final PageController _pageController;
  int _step = 0;

  String? _selectedLocation;
  bool _agreedToTerms = false;
  bool _showTermsError = false;

  static const _locationOptions = [
    'Auckland', 'Wellington', 'Christchurch', 'Hamilton', 'Tauranga',
    'Napier-Hastings', 'Dunedin', 'Palmerston North', 'Nelson', 'Rotorua',
    'New Plymouth', 'Whangarei', 'Invercargill', 'Whanganui', 'Gisborne',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  GlobalKey<FormState> get _currentFormKey {
    switch (_step) {
      case 0: return _nameFormKey;
      case 1: return _contactFormKey;
      case 2: return _locationFormKey;
      default: return _passwordFormKey;
    }
  }

  void _advance() {
    if (!_currentFormKey.currentState!.validate()) return;
    if (_step == 3) {
      _submit();
      return;
    }
    final next = _step + 1;
    setState(() => _step = next);
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_step == 0) return;
    final prev = _step - 1;
    setState(() => _step = prev);
    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _submit() async {
    if (!_agreedToTerms) {
      setState(() => _showTermsError = true);
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.signUp(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      '+64 ${_phoneController.text.trim()}',
      _selectedLocation!,
    );
    if (!mounted) return;
    if (auth.signUpSuccess) {
      context.go('/profile/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildNameStep(),
              _buildContactStep(authProvider),
              _buildLocationStep(),
              _buildPasswordStep(authProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 4),
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: _step > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: _step > 0 ? _back : null,
              color: themeText,
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (i) {
                  final active = i == _step;
                  final done = i < _step;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (active || done) ? themeAccent : themePrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _stepShell({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return _stepShell(
      child: Form(
        key: _nameFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's your name?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "We'll use this on your profile and bookings.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: themeTaupe,
                  ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _firstNameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'First name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Last name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
              onFieldSubmitted: (_) => _advance(),
            ),
            const SizedBox(height: 32),
            _continueButton(),
            const SizedBox(height: 20),
            _signInLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactStep(AuthProvider authProvider) {
    return _stepShell(
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How can we reach you?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Your email is used to sign in. Your phone stays private.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: themeTaupe,
                  ),
            ),
            if (authProvider.signUpErrorMessage.isNotEmpty &&
                !authProvider.isLoading) ...[
              const SizedBox(height: 16),
              _errorBanner(authProvider.signUpErrorMessage),
            ],
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [_NzPhoneFormatter()],
              decoration: InputDecoration(
                labelText: 'Phone number',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+64',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 1,
                      height: 16,
                      color: themePrimary,
                    ),
                  ],
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 9) return 'Enter a valid NZ phone number';
                return null;
              },
              onFieldSubmitted: (_) => _advance(),
            ),
            const SizedBox(height: 32),
            _continueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    return _stepShell(
      child: Form(
        key: _locationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Where are you based?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "This helps renters find dresses near them.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: themeTaupe,
                  ),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'City'),
              items: _locationOptions
                  .map((loc) =>
                      DropdownMenuItem(value: loc, child: Text(loc)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLocation = v),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please select a city' : null,
            ),
            const SizedBox(height: 32),
            _continueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStep(AuthProvider authProvider) {
    return _stepShell(
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create your password",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "At least 6 characters.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: themeTaupe,
                  ),
            ),
            if (authProvider.signUpErrorMessage.isNotEmpty &&
                !authProvider.isLoading) ...[
              const SizedBox(height: 16),
              _errorBanner(authProvider.signUpErrorMessage),
            ],
            const SizedBox(height: 32),
            PasswordField(
              controller: _passwordController,
              labelText: 'Password',
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 6) return 'Must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirmPasswordController,
              labelText: 'Confirm password',
              textInputAction: TextInputAction.done,
              onFieldSubmitted: _advance,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() {
                _agreedToTerms = !_agreedToTerms;
                if (_agreedToTerms) _showTermsError = false;
              }),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: themeAccent,
                    side: BorderSide(
                      color: _showTermsError ? themeRose : themePrimary,
                      width: 1.5,
                    ),
                    onChanged: (v) => setState(() {
                      _agreedToTerms = v!;
                      if (_agreedToTerms) _showTermsError = false;
                    }),
                  ),
                  Expanded(
                    child: Text(
                      "I agree to Aurae's Terms of Use and Privacy Policy",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            if (_showTermsError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'You must agree to continue.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: themeRose),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _advance,
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _advance,
        child: const Text('Continue'),
      ),
    );
  }

  Widget _signInLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          GestureDetector(
            onTap: () => context.go('/profile/signin'),
            child: Text(
              'Sign in',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: themeText,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: themeText,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeRose.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeRose.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: themeRose, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: themeRose),
            ),
          ),
        ],
      ),
    );
  }
}

// Formats digits as: XX XXXX XXXX (NZ local number, max 10 digits)
class _NzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final capped = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i == 2 || i == 6) buf.write(' ');
      buf.write(capped[i]);
    }

    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
