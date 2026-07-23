import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/logic/cart_provider.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/presentation/widgets/common/price_action_bar.dart';
import 'package:shine_app/presentation/widgets/listing/availability_calendar.dart';
import 'package:shine_app/presentation/widgets/listing/booking_flow_cards.dart';
import 'package:shine_app/presentation/widgets/listing/image_carousel.dart';
import 'package:shine_app/presentation/widgets/wardrobe/purchase_availability_calendar.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/date_range_selection.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
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

  // Booking flow state, lifted here since Size / Delivery / Dates are now
  // separate cards with a shared price/CTA bar at the bottom, rather than
  // one stateful panel.
  DateTime? _bookingStart;
  DateTime? _bookingEnd;
  String? _selectedDelivery;
  bool _isAddingToCart = false;
  int? _lastListingId;
  String? _lastDeliveryOption;

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

  // Matches ListingsPage's sidebar breakpoint so layout shifts happen at a
  // consistent width across the app.
  static const double _sidebarBreakpoint = 1000;

  Widget _buildContent(ListingDetailProvider provider) {
    final listing = provider.listing!;
    _syncBookingState(provider, listing);

    // The owner previewing their own public listing gets a simple "Manage
    // Dress" shortcut back into the Wardrobe — not a real booking/purchase
    // flow, so it keeps its original single-column layout.
    if (provider.isOwnListing) {
      return _buildOwnListingContent(provider, listing);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _sidebarBreakpoint) {
          return _buildWideContent(provider, listing);
        }
        return _buildNarrowContent(provider, listing);
      },
    );
  }

  // Switching size points the page at a different physical dress, with its
  // own availability — dates picked for the old one don't carry over. The
  // delivery choice defaults to the owner's only option, or resets to
  // unchosen if they offer both.
  void _syncBookingState(ListingDetailProvider provider, Listing listing) {
    if (_lastListingId != listing.id) {
      _lastListingId = listing.id;
      _bookingStart = null;
      _bookingEnd = null;
    }

    final deliveryOption = provider.listingOwner?.deliveryOption;
    if (_lastDeliveryOption != deliveryOption) {
      _lastDeliveryOption = deliveryOption;
      // Mirrors DeliveryChoiceCard's own default: no configured option
      // falls back to 'pickup', not to an unchosen state.
      final effectiveOption = deliveryOption ?? 'pickup';
      _selectedDelivery = effectiveOption != 'both' ? effectiveOption : null;
    }
  }

  Widget _buildOwnListingContent(ListingDetailProvider provider, Listing listing) {
    final isForBuy = listing.listingType == 'sell';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageCarousel(imageUrls: listing.imageUrls),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderBlock(provider, listing),
                          const SizedBox(height: 24),
                          _buildAboutSection(listing),
                          const SizedBox(height: 28),
                          const Divider(color: Color(0xFFEEE8E4)),
                          const SizedBox(height: 20),
                          _buildAvailabilityCalendar(provider),
                          const SizedBox(height: 28),
                          const Divider(color: Color(0xFFEEE8E4)),
                          const SizedBox(height: 20),
                          _buildOwnerRow(provider),
                          _buildDescriptionSection(listing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        PriceActionBar(
          price: listing.pricePerDay,
          priceLabel: isForBuy ? 'to purchase' : 'per day',
          buttonLabel: 'Manage Dress',
          buttonIcon: Icons.checkroom_outlined,
          onTap: () => context.go('/wardrobe/${listing.id}'),
        ),
      ],
    );
  }

  // Narrow / app layout: dress identity reads first (name, specs), then the
  // booking steps as their own cards, then the rest of the details. Price
  // and the CTA live in a bar pinned to the bottom of the screen.
  Widget _buildNarrowContent(ListingDetailProvider provider, Listing listing) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageCarousel(imageUrls: listing.imageUrls),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: _buildHeaderBlock(provider, listing),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: _buildBookingCards(provider, listing),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAboutSection(listing),
                          const SizedBox(height: 28),
                          const Divider(color: Color(0xFFEEE8E4)),
                          const SizedBox(height: 20),
                          _buildOwnerRow(provider),
                          _buildDescriptionSection(listing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildPriceActionBar(provider, listing),
      ],
    );
  }

  // Wide / web layout: dress details scroll on the left. The right-hand
  // sidebar holds the booking cards, with price + CTA pinned to the bottom
  // of that sidebar so it's always visible while choosing size/delivery/
  // dates, without following the left column's scroll.
  Widget _buildWideContent(ListingDetailProvider provider, Listing listing) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ImageCarousel(imageUrls: listing.imageUrls),
                      ),
                      const SizedBox(height: 20),
                      _buildHeaderBlock(provider, listing),
                      const SizedBox(height: 28),
                      _buildAboutSection(listing),
                      const SizedBox(height: 28),
                      const Divider(color: Color(0xFFEEE8E4)),
                      const SizedBox(height: 20),
                      _buildOwnerRow(provider),
                      _buildDescriptionSection(listing),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 28),
              SizedBox(
                width: 360,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildBookingCards(provider, listing),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildPriceActionBar(provider, listing),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Size / Delivery / Dates as distinct steps, separated by spacing and a
  // hairline divider rather than boxed cards — or a single Availability
  // step for purchase listings, which have no size or delivery choice.
  Widget _buildBookingCards(ListingDetailProvider provider, Listing listing) {
    if (listing.listingType == 'sell') {
      return BookingStepSection(
        title: 'Availability',
        child: PurchaseAvailabilityCalendar(availableFrom: listing.availableFrom),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizeChoiceCard(
          listing: listing,
          sizeVariants: provider.sizeVariants,
          isSwitching: provider.isSwitchingSize,
          onSizeSelected: (size) => provider.selectSize(size),
        ),
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFEEE8E4)),
        const SizedBox(height: 24),
        DeliveryChoiceCard(
          ownerDeliveryOption: provider.listingOwner?.deliveryOption,
          selected: _selectedDelivery,
          onChanged: (option) => setState(() => _selectedDelivery = option),
        ),
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFEEE8E4)),
        const SizedBox(height: 24),
        BookingDatesCard(
          pricePerDay: listing.pricePerDay,
          bookings: provider.bookings,
          start: _bookingStart,
          end: _bookingEnd,
          onDayTapped: (day) => _onDayTapped(day, provider.bookings),
        ),
      ],
    );
  }

  Widget _buildPriceActionBar(ListingDetailProvider provider, Listing listing) {
    final isForBuy = listing.listingType == 'sell';
    final price = isForBuy
        ? (listing.purchasePrice ?? listing.pricePerDay)
        : listing.pricePerDay;
    final hasSelection = _bookingStart != null && _bookingEnd != null;
    final deliveryChosen = isForBuy || _selectedDelivery != null;
    final enabled = !isForBuy && hasSelection && deliveryChosen;
    final label = isForBuy
        ? 'Purchase'
        : (!deliveryChosen
            ? 'Select delivery method'
            : (hasSelection ? 'Add to Cart' : 'Select dates above'));

    return PriceActionBar(
      price: price,
      priceLabel: isForBuy ? 'to purchase' : 'per day',
      pricePrefix: isForBuy ? null : 'From ',
      buttonLabel: label,
      buttonIcon: isForBuy ? Icons.shopping_bag_outlined : Icons.add_shopping_cart_outlined,
      enabled: enabled,
      isLoading: _isAddingToCart,
      onTap: (enabled && !isForBuy) ? () => _addToCart(context, provider) : null,
    );
  }

  // Dress identity: location/age, name (the page's actual title), and spec
  // chips. Reads first, before any booking mechanics.
  Widget _buildHeaderBlock(ListingDetailProvider provider, Listing listing) {
    final isForBuy = listing.listingType == 'sell';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location + age
        Row(
          children: [
            if (listing.location.isNotEmpty) ...[
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
            ],
            Text(
              _formatListingAge(listing.uploadDate),
              style: TextStyle(fontSize: 12, color: themeTaupe),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Public listing name, falling back to brand · style
        Text(
          listing.name ?? '${listing.brand} · ${listing.style}',
          style: Theme.of(context).textTheme.headlineMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 16),

        // Spec chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isForBuy)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: themeText,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sell_outlined, size: 14, color: Color(0xFFFFF8F6)),
                    const SizedBox(width: 6),
                    Text(
                      'For Sale',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFF8F6),
                      ),
                    ),
                  ],
                ),
              ),
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
            if (listing.dressType != null)
              _SpecChip(
                icon: Icons.checkroom,
                label: listing.dressType!,
              ),
          ],
        ),

        // For rentals, delivery is an interactive choice in the booking
        // cards instead of a static chip here.
        if (isForBuy && provider.listingOwner?.deliveryOption != null) ...[
          const SizedBox(height: 12),
          _buildDeliveryChip(provider.listingOwner!.deliveryOption!),
        ],
      ],
    );
  }

  // Recommended size, condition, and RRP — plain size is covered by the
  // header spec chip (and the Size card, for rentals), so it isn't repeated
  // here.
  Widget _buildAboutSection(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this dress',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeText,
          ),
        ),
        const SizedBox(height: 16),
        _buildAboutRow(
          'Recommended size',
          _formatRecommendedSize(listing),
        ),
        _buildAboutRow(
          'Condition',
          listing.condition.isNotEmpty ? listing.condition : '-',
        ),
        _buildAboutRow(
          'RRP',
          listing.purchasePrice != null
              ? formatPrice(listing.purchasePrice!)
              : '-',
        ),
      ],
    );
  }

  Widget _buildDeliveryChip(String deliveryOption) {
    final (IconData icon, String label) = switch (deliveryOption) {
      'postal' => (Icons.local_shipping_outlined, 'Postal only'),
      'both' => (Icons.swap_horiz, 'Pickup & postal'),
      _ => (Icons.storefront_outlined, 'Pickup only'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: themePrimary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: themeTaupe),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: themeTaupe,
            ),
          ),
        ],
      ),
    );
  }

  // Owner picks a fit note + optional alternate sizes as simple selects when
  // adding the dress; this turns that into one readable line instead of
  // making renters read raw field names.
  String _formatRecommendedSize(Listing listing) {
    final fitNote = listing.fitNote;
    final sizes = listing.recommendedSizes;

    if (fitNote == null && sizes.isEmpty) return '-';
    if (fitNote != null && sizes.isNotEmpty) {
      return '$fitNote — try ${sizes.join(', ')}';
    }
    if (fitNote != null) return fitNote;
    return 'Try ${sizes.join(', ')}';
  }

  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 14, height: 1.5, color: themeText),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // Description reads last on the page — after price/size/delivery/dates
  // and the owner card — since it's the most detail-heavy, least
  // decision-critical section.
  Widget _buildDescriptionSection(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Divider(color: Color(0xFFEEE8E4)),
        const SizedBox(height: 20),
        _buildGarmentFeatures(
          listing.description.isNotEmpty ? listing.description : '-',
        ),
      ],
    );
  }

  Widget _buildGarmentFeatures(String notes) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Garment Features',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: TextStyle(fontSize: 14, color: themeText, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCalendar(ListingDetailProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AvailabilityCalendar(bookedRanges: provider.bookings),
        ),
      ],
    );
  }

  Widget _buildOwnerRow(ListingDetailProvider provider) {
    final owner = provider.listingOwner;
    if (owner == null) return const SizedBox.shrink();

    final ownerId = provider.listing?.userIdFk;

    return GestureDetector(
      onTap: ownerId != null ? () => context.push('/owner/$ownerId') : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: owner.profilePhotoUrl != null
                ? NetworkImage(owner.profilePhotoUrl!)
                : const AssetImage('assets/imgs/default_profile.jpg') as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${owner.firstName} ${owner.lastName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeText,
                  ),
                ),
                if (owner.instagram != null)
                  Text(
                    '@${owner.instagram}',
                    style: TextStyle(fontSize: 12, color: themeTaupe),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: themeTaupe),
        ],
      ),
    );
  }

  void _onDayTapped(DateTime day, List<BookedRange> bookings) {
    final (start, end) = DateRangeSelection.onDayTapped(
      start: _bookingStart,
      end: _bookingEnd,
      day: day,
      bookedRanges: bookings,
    );
    setState(() {
      _bookingStart = start;
      _bookingEnd = end;
    });
  }

  // Cart requires a signed-in user; anonymous visitors get sent to sign in
  // instead of hitting the API and failing.
  Future<void> _addToCart(
    BuildContext context,
    ListingDetailProvider provider,
  ) async {
    if (_bookingStart == null || _bookingEnd == null) return;

    if (provider.currentUserId == null) {
      context.go('/profile/signin');
      return;
    }

    setState(() => _isAddingToCart = true);
    try {
      await context.read<CartProvider>().addItem(
        dressId: provider.listing!.id,
        startDate: _bookingStart!,
        endDate: _bookingEnd!,
      );
      if (!mounted) return;
      setState(() {
        _bookingStart = null;
        _bookingEnd = null;
        _isAddingToCart = false;
      });
      FeedbackHelpers.showSuccessSnackBar(context, 'Added to cart');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAddingToCart = false);
      final msg = e.toString().replaceFirst('Exception: ', '');
      FeedbackHelpers.showErrorSnackBar(
        context,
        msg.isNotEmpty ? msg : 'Could not add to cart. Try again.',
      );
    }
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
