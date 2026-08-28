import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/presentation/widgets/common/labeled_fab.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_action_menu.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_card.dart';
import 'package:shine_app/presentation/widgets/wardrobe/wardrobe_empty_state.dart';
import 'package:shine_app/presentation/widgets/wardrobe/wardrobe_error_state.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

/// The full inventory, and nothing else.
///
/// The Wardrobe overview mixes the dashboard, a short strip of dresses and the
/// week's schedule — useful for a glance, useless for actually working through
/// stock. This page is only the dresses: every active one, with the sold
/// archive underneath.
///
/// Access is already gated on the overview (signed in, business profile
/// active), and the shell's app bar supplies the back arrow, so neither is
/// repeated here.
class WardrobeDressesPage extends StatefulWidget {
  const WardrobeDressesPage({super.key});

  @override
  State<WardrobeDressesPage> createState() => _WardrobeDressesPageState();
}

class _WardrobeDressesPageState extends State<WardrobeDressesPage> {
  static const _horizontalPadding = AppConstants.spacingLarge * 2;

  @override
  void initState() {
    super.initState();
    // Reached from the overview the dresses are already loaded, but this URL is
    // linkable and survives a browser refresh — landing here cold would
    // otherwise show the empty state over a wardrobe that simply hasn't been
    // fetched. Guarded so arriving from the overview doesn't flash a spinner
    // over data that is already on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WardrobeProvider>();
      if (provider.dresses.isEmpty && !provider.isLoading) {
        provider.fetchDresses();
      }
    });
  }

  double _itemWidth(double availableWidth, int crossAxisCount) {
    final totalSpacing =
        _horizontalPadding + (AppConstants.spacingMedium * (crossAxisCount - 1));
    return (availableWidth - totalSpacing) / crossAxisCount;
  }

  void _handleAddDress(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);
    context.go('/wardrobe/add');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WardrobeProvider>();

    return Stack(
      children: [
        _buildBody(context, provider),
        LabeledFab(
          label: 'Add dress',
          onPressed: () => _handleAddDress(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WardrobeProvider provider) {
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
            final crossAxisCount =
                constraints.maxWidth >= AppConstants.twoColumnBreakpoint ? 2 : 1;
            final itemWidth = _itemWidth(constraints.maxWidth, crossAxisCount);

            return RefreshIndicator(
              onRefresh: provider.fetchDresses,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingLarge,
                  AppConstants.spacingExtraLarge,
                ),
                children: [
                  Row(
                    children: [
                      Text(
                        'All dresses',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                    children: provider.dressesByAttention.map((dress) {
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
                    _buildSoldSection(context, provider, itemWidth),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSoldSection(
    BuildContext context,
    WardrobeProvider provider,
    double itemWidth,
  ) {
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
}
