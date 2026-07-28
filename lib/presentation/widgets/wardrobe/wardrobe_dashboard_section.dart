import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/week_schedule_provider.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';

class WardrobeDashboardSection extends StatelessWidget {
  const WardrobeDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeekScheduleProvider>();

    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Non-critical section — if it fails to load, just hide it rather than
    // showing a second error state on top of the main wardrobe page.
    if (provider.hasError) {
      return const SizedBox.shrink();
    }

    final topDresses = provider.topDressesByRevenue();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: themeTaupe,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        _buildRevenueCard(provider.totalRevenue),
        if (topDresses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Top performers',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: themeTaupe,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < topDresses.length; i++) ...[
                  _topDressRow(context, i + 1, topDresses[i]),
                  if (i < topDresses.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: themePrimary.withValues(alpha: 0.5),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRevenueCard(double totalRevenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total revenue',
            style: TextStyle(fontSize: 12, color: themeTaupe),
          ),
          const SizedBox(height: 4),
          Text(
            formatPrice(totalRevenue.round()),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: themeText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topDressRow(BuildContext context, int rank, DressRevenue entry) {
    final dress = entry.dress;
    final publicName = dress.name?.isNotEmpty == true ? dress.name! : null;
    final label = dress.internalName?.isNotEmpty == true
        ? dress.internalName!
        : (publicName ?? '${dress.brand} ${dress.style}'.trim());

    return InkWell(
      onTap: () {
        final currentRoute = GoRouterState.of(context).uri.path;
        context.read<BackButtonProvider>().pushRoute(currentRoute);
        context.go('/wardrobe/${dress.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: themeTaupe,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label.isNotEmpty ? label : 'Dress #${dress.id}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatPrice(entry.revenue.round()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: themeText,
                  ),
                ),
                if (entry.rentalCount > 0)
                  Text(
                    '${entry.rentalCount} rental${entry.rentalCount == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 11, color: themeTaupe),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
