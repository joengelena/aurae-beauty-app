import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/presentation/widgets/common/labeled_fab.dart';
import 'package:shine_app/presentation/widgets/sign_in_to_access.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_action_menu.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_card.dart';
import 'package:shine_app/presentation/widgets/wardrobe/wardrobe_empty_state.dart';
import 'package:shine_app/presentation/widgets/wardrobe/wardrobe_error_state.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:provider/provider.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  static const _horizontalPadding = AppConstants.spacingLarge * 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().fetchDresses();
    });
  }

  double _calculateItemWidth(double availableWidth, int crossAxisCount) {
    final totalSpacing =
        _horizontalPadding + (AppConstants.spacingMedium * (crossAxisCount - 1));
    return (availableWidth - totalSpacing) / crossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(message: 'Sign in to access your wardrobe.');
    }

    final wardrobeProvider = context.watch<WardrobeProvider>();

    return Stack(
      children: [
        _buildBody(wardrobeProvider),
        LabeledFab(label: 'Add', onPressed: _handleAddDress),
      ],
    );
  }

  Widget _buildBody(WardrobeProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
          child: WardrobeErrorState(
            errorMessage: provider.errorMessage,
            onRetry: provider.fetchDresses,
          ),
        ),
      );
    }

    if (provider.dresses.isEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
          child: const WardrobeEmptyState(),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final crossAxisCount =
                availableWidth >= AppConstants.twoColumnBreakpoint ? 2 : 1;
            final itemWidth = _calculateItemWidth(availableWidth, crossAxisCount);

            return RefreshIndicator(
              onRefresh: provider.fetchDresses,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingExtraLarge,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppConstants.spacingLarge),
                    child: Text(
                      'My Wardrobe',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Wrap(
                    spacing: AppConstants.spacingMedium,
                    runSpacing: AppConstants.spacingMedium,
                    children: provider.dresses.map((dress) {
                      return SizedBox(
                        width: itemWidth,
                        child: DressCard(
                          dress: dress,
                          actionButton: DressActionMenu(dress: dress),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleAddDress() {
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);
    context.go('/wardrobe/add');
  }
}
