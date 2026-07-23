import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/cart_item.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/logic/cart_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_empty_state.dart';
import 'package:shine_app/presentation/widgets/sign_in_to_access.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isSignedIn) {
      return const SignInToAccess(
        icon: Icons.shopping_bag_outlined,
        title: 'Your cart',
        subtitle: 'Sign in to review the dresses you\'ve picked dates for.',
      );
    }

    final cartProvider = context.watch<CartProvider>();

    if (cartProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cartProvider.errorMessage!,
              style: TextStyle(color: themeRed),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => cartProvider.fetchCart(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (cartProvider.items.isEmpty) {
      return AppEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Your cart is empty',
        body: 'Pick dates on a dress you love and add it here.',
        action: ElevatedButton(
          onPressed: () => context.go('/listings'),
          child: const Text('Explore dresses'),
        ),
      );
    }

    final total = cartProvider.items.fold<int>(0, (sum, item) => sum + item.totalPrice);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: RefreshIndicator(
                onRefresh: () => cartProvider.fetchCart(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _CartItemTile(
                      item: item,
                      dateLabel: '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
                      onRemove: () async {
                        try {
                          await cartProvider.removeItem(item.id);
                          if (context.mounted) {
                            FeedbackHelpers.showSuccessSnackBar(
                              context,
                              'Removed from cart',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            FeedbackHelpers.showErrorSnackBar(
                              context,
                              'Failed to remove from cart',
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        _CartSummaryBar(total: total),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final String dateLabel;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.dateLabel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/listings/${item.dressIdFk}'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: themePrimary.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 90,
                  height: 110,
                  child: ColoredBox(
                    color: const Color(0xFFF5EFED),
                    child: item.dressPhotoUrl.isEmpty
                        ? Icon(Icons.checkroom_outlined, color: themeTaupe)
                        : CachedNetworkImage(
                            imageUrl: item.dressPhotoUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return Icon(Icons.broken_image, color: themeTaupe);
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      item.name ?? item.style,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: themeText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.brand} · Size ${item.size}',
                      style: TextStyle(fontSize: 12, color: themeTaupe),
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: themeTaupe),
                        const SizedBox(width: 4),
                        Text(
                          dateLabel,
                          style: TextStyle(fontSize: 12, color: themeTaupe),
                        ),
                      ],
                    ),
                    Text(
                      '${item.nights} ${item.nights == 1 ? 'day' : 'days'} · ${formatPrice(item.totalPrice)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: themeText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
                color: themeTaupe,
                tooltip: 'Remove',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final int total;

  const _CartSummaryBar({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatPrice(total),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: themeText,
                  ),
                ),
                Text(
                  'Estimated total',
                  style: TextStyle(fontSize: 12, color: themeTaupe),
                ),
              ],
            ),
          ),
          // Checkout is a placeholder until payments are built.
          Opacity(
            opacity: 0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: themeText,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Text(
                'Checkout — coming soon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFF8F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
