import 'package:flutter/material.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';

class PriceActionBar extends StatelessWidget {
  const PriceActionBar({
    super.key,
    required this.price,
    required this.priceLabel,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onTap,
    this.pricePrefix,
    this.enabled = true,
    this.isLoading = false,
  });

  final int price;
  final String priceLabel;
  final String? pricePrefix;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback? onTap;

  /// When false, the button dims and stops responding to taps — used while
  /// a prior step (size, delivery, dates) hasn't been completed yet.
  final bool enabled;

  /// Swaps the button content for a spinner while a request is in flight.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final tapEnabled = enabled && !isLoading;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F6),
          border: Border(
            top: BorderSide(color: Color(0xFFEEE8E4), width: 1),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${pricePrefix ?? ''}${formatPrice(price)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: themeText,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  priceLabel,
                  style: TextStyle(fontSize: 12, color: themeTaupe),
                ),
              ],
            ),
            const Spacer(),
            Opacity(
              opacity: tapEnabled || isLoading ? 1 : 0.4,
              child: GestureDetector(
                onTap: tapEnabled ? onTap : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: themeText,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFF8F6),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(buttonIcon, size: 16, color: const Color(0xFFFFF8F6)),
                            const SizedBox(width: 8),
                            Text(
                              buttonLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFF8F6),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
