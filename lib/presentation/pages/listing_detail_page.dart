import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/services/dress_services.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/presentation/widgets/common/price_action_bar.dart';
import 'package:shine_app/presentation/widgets/listing/availability_calendar.dart';
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

                          // Brand · style
                          Text(
                            '${listing.brand} · ${listing.style}',
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

                          _buildAvailabilityCalendar(provider),

                          const SizedBox(height: 28),
                          const Divider(color: Color(0xFFEEE8E4)),
                          const SizedBox(height: 20),

                          _buildOwnerRow(provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (provider.isOwnListing)
          PriceActionBar(
            price: listing.pricePerDay,
            priceLabel: isForBuy ? 'to purchase' : 'per day',
            buttonLabel: 'Manage Dress',
            buttonIcon: Icons.checkroom_outlined,
            onTap: () => context.go('/wardrobe/${listing.id}'),
          )
        else
          PriceActionBar(
            price: listing.pricePerDay,
            priceLabel: isForBuy ? 'to purchase' : 'per day',
            buttonLabel: isForBuy ? 'Purchase' : 'Select Dates',
            buttonIcon: isForBuy
                ? Icons.shopping_bag_outlined
                : Icons.calendar_today_outlined,
            onTap: isForBuy
                ? null
                : () => _openDateSelector(context, provider),
          ),
      ],
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

  void _openDateSelector(BuildContext context, ListingDetailProvider provider) {
    final listing = provider.listing!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DateSelectionSheet(
        dressId: listing.id,
        bookedRanges: provider.bookings,
        pricePerDay: listing.pricePerDay,
        dressTitle: listing.name ?? '${listing.brand} ${listing.style}',
        onBooked: () => provider.getListing(listing.id),
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

// ─── Date selection bottom sheet ─────────────────────────────────────────────

class _DateSelectionSheet extends StatefulWidget {
  final int dressId;
  final List<BookedRange> bookedRanges;
  final int pricePerDay;
  final String dressTitle;
  final VoidCallback? onBooked;

  const _DateSelectionSheet({
    required this.dressId,
    required this.bookedRanges,
    required this.pricePerDay,
    required this.dressTitle,
    this.onBooked,
  });

  @override
  State<_DateSelectionSheet> createState() => _DateSelectionSheetState();
}

class _DateSelectionSheetState extends State<_DateSelectionSheet> {
  DateTime? _start;
  DateTime? _end;
  bool _isSubmitting = false;

  void _onDayTapped(DateTime day) {
    setState(() {
      if (_start == null) {
        // First tap: set start
        _start = day;
        _end = null;
      } else if (_end == null) {
        final tapped = DateTime(day.year, day.month, day.day);
        final s = DateTime(_start!.year, _start!.month, _start!.day);

        if (tapped == s) {
          // Tap same day: clear
          _start = null;
        } else if (tapped.isBefore(s)) {
          // Tapped before start: make it the new start
          _start = day;
        } else {
          // Check no unavailable days fall within the proposed range
          final hasConflict = widget.bookedRanges.any((r) {
            if (!r.isUnavailable) return false;
            final rs = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
            final re = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
            // Conflict if any booked day overlaps [start+1 .. tapped]
            return rs.isBefore(tapped) && re.isAfter(s);
          });

          if (hasConflict) {
            // Can't book across an unavailable range — restart selection
            _start = day;
            _end = null;
          } else {
            _end = day;
          }
        }
      } else {
        // Third tap: restart selection
        _start = day;
        _end = null;
      }
    });
  }

  int get _nights {
    if (_start == null || _end == null) return 0;
    return _end!.difference(_start!).inDays + 1;
  }

  int get _totalPrice => _nights * widget.pricePerDay;

  String _formatShort(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }

  Future<void> _submitBooking() async {
    if (_start == null || _end == null) return;
    setState(() => _isSubmitting = true);
    try {
      await DressServices().selfBook(
        dressId: widget.dressId,
        startDate: _start!,
        endDate: _end!,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onBooked?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking request sent!'),
          backgroundColor: themeText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isNotEmpty ? msg : 'Could not create booking. Try again.'),
          backgroundColor: themeRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _start != null && _end != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD4CF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select dates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: themeText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasSelection
                                ? '${_formatShort(_start!)} – ${_formatShort(_end!)} · $_nights ${_nights == 1 ? 'day' : 'days'}'
                                : _start != null
                                    ? 'Now pick an end date'
                                    : 'Tap a date to start',
                            style: TextStyle(fontSize: 13, color: themeTaupe),
                          ),
                        ],
                      ),
                    ),
                    if (_start != null)
                      GestureDetector(
                        onTap: () => setState(() { _start = null; _end = null; }),
                        child: Text(
                          'Clear',
                          style: TextStyle(fontSize: 13, color: themeAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Calendar
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Container(
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
                    child: AvailabilityCalendar(
                      bookedRanges: widget.bookedRanges,
                      selectionStart: _start,
                      selectionEnd: _end,
                      onDayTapped: _onDayTapped,
                    ),
                  ),
                ),
              ),

              // Booking summary + confirm button
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: hasSelection
                    ? Container(
                        padding: EdgeInsets.fromLTRB(
                          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
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
                                    formatPrice(_totalPrice),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: themeText,
                                    ),
                                  ),
                                  Text(
                                    '$_nights ${_nights == 1 ? 'day' : 'days'} · ${formatPrice(widget.pricePerDay)}/day',
                                    style: TextStyle(fontSize: 12, color: themeTaupe),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _isSubmitting ? null : _submitBooking,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                decoration: BoxDecoration(
                                  color: _isSubmitting
                                      ? themeAccent.withValues(alpha: 0.6)
                                      : themeAccent,
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: _isSubmitting
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: themeAccent.withValues(alpha: 0.38),
                                            blurRadius: 14,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: themeText,
                                        ),
                                      )
                                    : Text(
                                        'Confirm booking',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: themeText,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
