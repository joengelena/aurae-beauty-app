import 'package:flutter/material.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/presentation/widgets/listing/contact_seller.dart';
import 'package:shine_app/presentation/widgets/listing/image_carousel.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ListingDetailPage extends StatefulWidget {
  const ListingDetailPage({super.key, required this.listingId});
  final String listingId;

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label, this.primary = false});

  final IconData icon;
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final bg = primary
        ? themeAccent.withValues(alpha: 0.18)
        : themePrimary.withValues(alpha: 0.35);
    final fg = primary ? themeText : themeTaupe;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingDetailPageState extends State<ListingDetailPage>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;
  bool _hasFiredLoad = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _hasFiredLoad = true);
      context.read<ListingDetailProvider>().getListing(
        int.parse(widget.listingId),
      );
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String _formatListingAge(DateTime uploadDate) {
    final difference = DateTime.now().difference(uploadDate);
    if (difference.inDays == 0) return 'Listed today';
    if (difference.inDays == 1) return 'Listed yesterday';
    return 'Listed ${difference.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingDetailProvider>();

    if (provider.isLoading || !_hasFiredLoad) {
      return _buildSkeleton();
    }

    if (provider.listing == null) {
      return _buildNotFound();
    }

    return _buildContent(provider);
  }

  Widget _buildContent(ListingDetailProvider provider) {
    final listing = provider.listing!;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageCarousel(imageUrls: listing.imageUrls),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location + age
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: themeTaupe,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            style: TextStyle(fontSize: 13, color: themeTaupe),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatListingAge(listing.uploadDate),
                          style: TextStyle(fontSize: 12, color: themeTaupe),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Brand · style
                    Text(
                      '${listing.brand} · ${listing.style}',
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatPrice(listing.pricePerDay),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: themeText,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '/ day',
                          style: TextStyle(fontSize: 14, color: themeTaupe),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Spec chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SpecChip(
                          icon: Icons.straighten,
                          label: listing.size,
                          primary: true,
                        ),
                        _SpecChip(
                          icon: Icons.check_circle_outline,
                          label: listing.condition,
                          primary: true,
                        ),
                        if (listing.color != null)
                          _SpecChip(
                            icon: Icons.palette_outlined,
                            label: listing.color!,
                          ),
                        if (listing.dressType != null)
                          _SpecChip(
                            icon: Icons.checkroom,
                            label: listing.dressType!,
                          ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFFEEE8E4)),
                    const SizedBox(height: 20),

                    // About this dress
                    Text(
                      'About this dress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      listing.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeText,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFFEEE8E4)),
                    const SizedBox(height: 20),

                    // Contact to book
                    Text(
                      'Contact to book',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ContactSeller(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: themeAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 44,
                color: themeAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Dress not found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This dress may no longer be available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeTaupe,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          const Color(0xFFEFE9E6),
          const Color(0xFFE0D5D0),
          _shimmerAnimation.value,
        )!;

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: AppConstants.listingImageAspectRatio,
                    child: Container(color: shimmerColor),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location row
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              height: 12,
                              width: 130,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              height: 11,
                              width: 90,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Container(
                          height: 22,
                          width: 220,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 16,
                          width: 160,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Price
                        Container(
                          height: 28,
                          width: 100,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Chips
                        Row(
                          children: [
                            _skeletonChip(shimmerColor, 70),
                            const SizedBox(width: 8),
                            _skeletonChip(shimmerColor, 80),
                            const SizedBox(width: 8),
                            _skeletonChip(shimmerColor, 60),
                          ],
                        ),

                        const SizedBox(height: 28),
                        Divider(color: shimmerColor),
                        const SizedBox(height: 20),

                        // Description heading
                        Container(
                          height: 14,
                          width: 110,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description lines
                        _skeletonLine(shimmerColor),
                        const SizedBox(height: 7),
                        _skeletonLine(shimmerColor),
                        const SizedBox(height: 7),
                        _skeletonLine(shimmerColor, endFraction: 0.65),

                        const SizedBox(height: 28),
                        Divider(color: shimmerColor),
                        const SizedBox(height: 20),

                        // Contact heading
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contact card skeleton
                        Container(
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 14,
                                        width: 110,
                                        decoration: BoxDecoration(
                                          color: shimmerColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 11,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: shimmerColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Divider(color: shimmerColor, height: 1),
                              const SizedBox(height: 12),
                              _skeletonLine(shimmerColor, endFraction: 0.7),
                              const SizedBox(height: 10),
                              _skeletonLine(shimmerColor, endFraction: 0.6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _skeletonLine(Color color, {double endFraction = 1.0}) {
    return Row(
      children: [
        Expanded(
          flex: (endFraction * 100).round(),
          child: Container(
            height: 13,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        if (endFraction < 1.0)
          Spacer(flex: ((1.0 - endFraction) * 100).round()),
      ],
    );
  }

  Widget _skeletonChip(Color color, double width) {
    return Container(
      height: 34,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
