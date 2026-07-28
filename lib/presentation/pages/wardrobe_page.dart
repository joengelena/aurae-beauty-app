import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/logic/week_schedule_provider.dart';
import 'package:shine_app/presentation/widgets/common/labeled_fab.dart';
import 'package:shine_app/presentation/widgets/profile/week_schedule_widget.dart';
import 'package:shine_app/presentation/widgets/sign_in_to_access.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_action_menu.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_card.dart';
import 'package:shine_app/presentation/widgets/wardrobe/wardrobe_empty_state.dart';
import 'package:shine_app/presentation/widgets/wardrobe/wardrobe_error_state.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage>
    with TickerProviderStateMixin {
  static const _horizontalPadding = AppConstants.spacingLarge * 2;

  late AnimationController _skeletonController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmerAnimation = CurvedAnimation(
      parent: _skeletonController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().fetchDresses();
      context.read<WeekScheduleProvider>().load();
    });
  }

  @override
  void dispose() {
    _skeletonController.dispose();
    super.dispose();
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
      return const SignInToAccess(
        icon: Icons.checkroom_outlined,
        title: 'Your wardrobe',
        subtitle: 'Sign in to manage your dresses, track rentals, and list items for others to borrow.',
      );
    }

    final wardrobeProvider = context.watch<WardrobeProvider>();

    return Stack(
      children: [
        _buildBody(wardrobeProvider),
        LabeledFab(label: 'Add dress', onPressed: _handleAddDress),
      ],
    );
  }

  Widget _buildBody(WardrobeProvider provider) {
    if (provider.isLoading) {
      return _buildSkeleton();
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
              onRefresh: () async {
                await Future.wait([
                  provider.fetchDresses(),
                  context.read<WeekScheduleProvider>().load(),
                ]);
              },
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingExtraLarge,
                ),
                children: [
                  // Heading aligned with the card grid
                  Row(
                    children: [
                      Text(
                        'My Wardrobe',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${provider.activeDresses.length} dress${provider.activeDresses.length == 1 ? '' : 'es'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeTaupe,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Wrap(
                    spacing: AppConstants.spacingMedium,
                    runSpacing: AppConstants.spacingMedium,
                    children: provider.activeDresses.map((dress) {
                      return SizedBox(
                        width: itemWidth,
                        child: DressCard(
                          dress: dress,
                          actionButton: DressActionMenu(dress: dress),
                        ),
                      );
                    }).toList(),
                  ),
                  if (provider.soldDresses.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingLarge),
                    _buildSoldSection(provider, itemWidth),
                  ],
                  const SizedBox(height: AppConstants.spacingLarge),
                  Divider(color: themePrimary, thickness: 1),
                  const SizedBox(height: AppConstants.spacingMedium),
                  const WeekScheduleWidget(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSoldSection(WardrobeProvider provider, double itemWidth) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: AppConstants.spacingMedium),
        title: Text(
          'Sold (${provider.soldDresses.length})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: themeTaupe,
          ),
        ),
        children: [
          Wrap(
            spacing: AppConstants.spacingMedium,
            runSpacing: AppConstants.spacingMedium,
            children: provider.soldDresses.map((dress) {
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
  }

  Widget _buildSkeleton() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final crossAxisCount =
                availableWidth >= AppConstants.twoColumnBreakpoint ? 2 : 1;
            final itemWidth = _calculateItemWidth(availableWidth, crossAxisCount);
            final cardCount = crossAxisCount == 2 ? 4 : 3;

            return AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, _) {
                final shimmerColor = Color.lerp(
                  const Color(0xFFEFE9E6),
                  const Color(0xFFE0D5D0),
                  _shimmerAnimation.value,
                )!;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.spacingLarge,
                    AppConstants.spacingLarge,
                    AppConstants.spacingLarge,
                    AppConstants.spacingExtraLarge,
                  ),
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 120,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Wrap(
                      spacing: AppConstants.spacingMedium,
                      runSpacing: AppConstants.spacingMedium,
                      children: List.generate(cardCount, (_) {
                        return SizedBox(
                          width: itemWidth,
                          child: _skeletonCard(itemWidth, shimmerColor),
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _skeletonCard(double width, Color shimmerColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: AppConstants.listingImageAspectRatio,
              child: Container(color: shimmerColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + action menu stub
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 13,
                            width: width * 0.60,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 11,
                            width: width * 0.44,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Chip row stub
                Row(
                  children: [
                    Container(
                      height: 22,
                      width: 40,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      height: 22,
                      width: 52,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 13,
                  width: width * 0.38,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddDress() {
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);
    context.go('/wardrobe/add');
  }
}
