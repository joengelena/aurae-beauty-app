import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/dress_detail_provider.dart';
import 'package:shine_app/presentation/widgets/common/price_action_bar.dart';
import 'package:shine_app/presentation/widgets/wardrobe/booking_calendar.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_action_menu.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class DressDetailPage extends StatefulWidget {
  final String dressId;

  const DressDetailPage({super.key, required this.dressId});

  @override
  State<DressDetailPage> createState() => _DressDetailPageState();
}

class _DressDetailPageState extends State<DressDetailPage>
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
      context.read<DressDetailProvider>().loadDress(int.parse(widget.dressId));
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DressDetailProvider>();

    if (provider.isLoading || !_hasFiredLoad) {
      return _buildSkeleton();
    }

    if (provider.hasError || provider.dress == null) {
      return _buildError(provider);
    }

    return _buildContent(provider);
  }

  // ─── Content ─────────────────────────────────────────────────────────────────

  Widget _buildContent(DressDetailProvider provider) {
    final dress = provider.dress!;
    final now = DateTime.now();
    final allBookings = provider.bookings;

    final upcoming = allBookings
        .where((b) => b.endDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final past = allBookings
        .where((b) => !b.endDate.isAfter(now))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadDress(dress.id),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhotoHeader(dress),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + action menu
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildTitle(dress)),
                                DressActionMenu(dress: dress, redirectAfterDelete: true),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Attribute chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _attrChip('Size ${dress.size}'),
                                if (dress.color != null) _attrChip(dress.color!),
                                _conditionChip(dress.condition),
                                if (dress.purchaseYear != null)
                                  _attrChip('${dress.purchaseYear}'),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Current status
                            _buildStatusPill(allBookings, now),

                            // Damage notice
                            if (dress.damageDescription != null) ...[
                              const SizedBox(height: 10),
                              _buildDamageNotice(dress.damageDescription!),
                            ],

                            // Notes
                            if (dress.notes != null && dress.notes!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _buildNotesSection(dress.notes!),
                            ],

                            const SizedBox(height: 28),

                            // iOS-style uppercase section header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'RENTAL BOOKINGS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: themeTaupe,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                const Spacer(),
                                if ((dress.rentalCount ?? 0) > 0) ...[
                                  Text(
                                    '${dress.rentalCount} total',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: themeTaupe,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                _addBookingButton(dress.id),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _buildAvailabilityCalendar(allBookings),

                            const SizedBox(height: 16),

                            _buildBookingsBody(provider, dress.id, upcoming, past),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildStickyBar(dress),
      ],
    );
  }

  // ─── Sticky bottom bar ───────────────────────────────────────────────────────

  Widget _buildStickyBar(BusinessDress dress) {
    final isForBuy = dress.listingType == 'buy';
    final price = isForBuy ? dress.purchasePrice : dress.rentalPricePerDay;
    if (price == null) return const SizedBox.shrink();

    return PriceActionBar(
      price: price,
      priceLabel: isForBuy ? 'to purchase' : 'per day',
      buttonLabel: isForBuy ? 'Purchase' : 'Select Dates',
      buttonIcon: isForBuy
          ? Icons.shopping_bag_outlined
          : Icons.calendar_today_outlined,
      onTap: () => _handleAddBooking(context, dress.id),
    );
  }

  Widget _buildPhotoHeader(BusinessDress dress) {
    final Widget photo;
    if (dress.dressPhotoUrl == null) {
      photo = Container(
        color: const Color(0xFFF5EFED),
        child: Center(
          child: Icon(Icons.checkroom_outlined, color: themeTaupe, size: 48),
        ),
      );
    } else {
      photo = Image.network(
        dress.dressPhotoUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: const Color(0xFFF5EFED));
        },
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF5EFED),
          child: Center(
            child: Icon(Icons.checkroom_outlined, color: themeTaupe, size: 48),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: AppConstants.listingImageAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          photo,
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    themeBackground.withValues(alpha: 0),
                    themeBackground.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BusinessDress dress) {
    if (dress.internalName != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dress.internalName!,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: themeText,
              height: 1.15,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${dress.brand} · ${dress.style}',
            style: TextStyle(fontSize: 13, color: themeTaupe, letterSpacing: 0.1),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dress.brand,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: themeText,
            height: 1.15,
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dress.style,
          style: TextStyle(fontSize: 13, color: themeTaupe, letterSpacing: 0.1),
        ),
      ],
    );
  }

  Widget _buildStatusPill(List<RentalBooking> bookings, DateTime now) {
    // Overdue: active but end date has already passed
    final overdueMatches = bookings.where(
      (b) => b.status == 'active' && b.endDate.isBefore(now),
    );
    if (overdueMatches.isNotEmpty) {
      final b = overdueMatches.first;
      return _pillWidget(
        icon: Icons.warning_amber_outlined,
        label: 'Overdue return',
        sublabel: 'Was due ${formatDate(b.endDate)}',
        bg: themeRose.withValues(alpha: 0.10),
        fg: themeRose,
      );
    }

    // Currently out for rent
    final activeMatches = bookings.where(
      (b) =>
          (b.status == 'active' || b.status == 'confirmed') &&
          b.startDate.isBefore(now) &&
          b.endDate.isAfter(now),
    );
    if (activeMatches.isNotEmpty) {
      final b = activeMatches.first;
      return _pillWidget(
        icon: Icons.local_shipping_outlined,
        label: 'Out for rent',
        sublabel: 'Returns ${formatDate(b.endDate)}',
        bg: themePeach.withValues(alpha: 0.10),
        fg: themePeach,
      );
    }

    // Next confirmed or pending booking
    final nextMatches = bookings
        .where(
          (b) =>
              b.startDate.isAfter(now) &&
              (b.status == 'confirmed' || b.status == 'pending'),
        )
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (nextMatches.isNotEmpty) {
      final b = nextMatches.first;
      return _pillWidget(
        icon: Icons.event_outlined,
        label: 'Booked from ${formatDate(b.startDate)}',
        sublabel: null,
        bg: themeAccent.withValues(alpha: 0.15),
        fg: themeText,
      );
    }

    return _pillWidget(
      icon: Icons.check_circle_outline,
      label: 'Available now',
      sublabel: null,
      bg: themeSage.withValues(alpha: 0.10),
      fg: themeSage,
    );
  }

  Widget _pillWidget({
    required IconData icon,
    required String label,
    String? sublabel,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: fg.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDamageNotice(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeRose.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, size: 16, color: themeRose),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Damage noted',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: themeRose,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: themeTaupe,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: TextStyle(fontSize: 13, color: themeText, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _addBookingButton(int dressId) {
    return GestureDetector(
      onTap: () => _handleAddBooking(context, dressId),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: themeAccent.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeAccent.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 13, color: themeText),
            const SizedBox(width: 4),
            Text(
              'Add booking',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: themeText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCalendar(List<RentalBooking> bookings) {
    return Container(
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
      child: BookingCalendar(bookings: bookings),
    );
  }

  // ─── Bookings ─────────────────────────────────────────────────────────────────

  Widget _buildBookingsBody(
    DressDetailProvider provider,
    int dressId,
    List<RentalBooking> upcoming,
    List<RentalBooking> past,
  ) {
    if (provider.isLoadingBookings) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: themeAccent, strokeWidth: 2),
        ),
      );
    }

    if (upcoming.isEmpty && past.isEmpty) {
      return _buildBookingsEmptyState(dressId);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...upcoming.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _bookingTile(b, dressId, faded: false),
          ),
        ),

        if (past.isNotEmpty) ...[
          if (upcoming.isNotEmpty) const SizedBox(height: 6),
          if (upcoming.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'PAST RENTALS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: themeTaupe,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ...past.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _bookingTile(b, dressId, faded: true),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBookingsEmptyState(int dressId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
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
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: themeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_outlined,
              size: 26,
              color: themeAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a booking to start tracking rentals for this dress.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: themeTaupe, height: 1.4),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _handleAddBooking(context, dressId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: themeAccent.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeAccent.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Text(
                'Add first booking',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingTile(RentalBooking booking, int dressId, {required bool faded}) {
    final dateRange =
        '${formatDate(booking.startDate)} – ${formatDate(booking.endDate)}';
    final days = booking.endDate.difference(booking.startDate).inDays + 1;

    return Opacity(
      opacity: faded ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range + status chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeText,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _statusChip(booking.status),
              ],
            ),

            const SizedBox(height: 6),

            // Renter info + duration
            Row(
              children: [
                Icon(Icons.person_outline, size: 13, color: themeTaupe),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.renterName.isNotEmpty ? booking.renterName : booking.bookingType,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeTaupe,
                      fontStyle: booking.renterName.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: TextStyle(fontSize: 12, color: themeTaupe),
                ),
              ],
            ),

            // Cost + notes
            if (booking.totalCost > 0) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (booking.notes != null && booking.notes!.isNotEmpty)
                    Expanded(
                      child: Text(
                        booking.notes!,
                        style: TextStyle(
                          fontSize: 11,
                          color: themeTaupe,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const Spacer(),
                  Text(
                    formatPrice(booking.totalCost.toInt()),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeText,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 6),

            // Delete action
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _handleDeleteBooking(context, booking, dressId),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 13,
                        color: themeRose.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 11,
                          color: themeRose.withValues(alpha: 0.65),
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

  Widget _statusChip(String status) {
    final bg = switch (status) {
      'confirmed' => themeSage.withValues(alpha: 0.12),
      'active' => themePeach.withValues(alpha: 0.12),
      'returned' => const Color(0xFFF5EFED),
      'pending' => themeAccent.withValues(alpha: 0.18),
      'cancelled' => themeRose.withValues(alpha: 0.10),
      _ => const Color(0xFFF5EFED),
    };
    final fg = switch (status) {
      'confirmed' => themeSage,
      'active' => themePeach,
      'returned' => themeTaupe,
      'pending' => themeText,
      'cancelled' => themeRose,
      _ => themeTaupe,
    };
    final label = switch (status) {
      'confirmed' => 'Confirmed',
      'active' => 'Out for rent',
      'returned' => 'Returned',
      'pending' => 'Pending',
      'cancelled' => 'Cancelled',
      _ => status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _attrChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: themeTaupe)),
    );
  }

  Widget _conditionChip(String condition) {
    final lower = condition.toLowerCase();
    final Color bg;
    final Color text;
    if (lower == 'poor' || lower == 'damaged') {
      bg = themeRose.withValues(alpha: 0.10);
      text = themeRose;
    } else if (lower == 'fair') {
      bg = themePeach.withValues(alpha: 0.12);
      text = themePeach;
    } else {
      bg = const Color(0xFFF5EFED);
      text = themeTaupe;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(condition, style: TextStyle(fontSize: 11, color: text)),
    );
  }

  // ─── Loading skeleton ─────────────────────────────────────────────────────────

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
                        // Title + menu stub
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 20,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: shimmerColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 13,
                                    width: 140,
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

                        const SizedBox(height: 12),

                        // Chips
                        Row(
                          children: [
                            _skeletonChip(shimmerColor, 60),
                            const SizedBox(width: 6),
                            _skeletonChip(shimmerColor, 72),
                            const SizedBox(width: 6),
                            _skeletonChip(shimmerColor, 55),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Price
                        Container(
                          height: 22,
                          width: 84,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Status pill stub
                        Container(
                          height: 40,
                          width: 168,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Divider(color: shimmerColor),
                        const SizedBox(height: 16),

                        // Bookings heading
                        Row(
                          children: [
                            Container(
                              height: 14,
                              width: 130,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _skeletonBookingTile(shimmerColor),
                        const SizedBox(height: 10),
                        _skeletonBookingTile(shimmerColor),
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

  Widget _skeletonBookingTile(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 13,
                width: 160,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                height: 22,
                width: 70,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 11,
                width: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                height: 11,
                width: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeletonChip(Color color, double width) {
    return Container(
      height: 24,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────────────────

  Widget _buildError(DressDetailProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: themeRose.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 32, color: themeRose),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load dress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: themeTaupe, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  provider.loadDress(int.parse(widget.dressId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _handleDeleteBooking(
    BuildContext context,
    RentalBooking booking,
    int dressId,
  ) async {
    final confirmed = await FeedbackHelpers.showDeleteConfirmation(
      context,
      title: 'Delete Booking',
      message: 'Delete this booking? This cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await context.read<DressDetailProvider>().deleteBooking(
        booking.id,
        dressId,
      );
      if (context.mounted) {
        FeedbackHelpers.showSuccessSnackBar(context, 'Booking deleted');
      }
    } catch (e) {
      if (context.mounted) {
        FeedbackHelpers.showErrorSnackBar(context, 'Failed to delete booking.');
      }
    }
  }

  void _handleAddBooking(BuildContext context, int dressId) {
    final currentRoute = GoRouterState.of(context).uri.path;
    context.read<BackButtonProvider>().pushRoute(currentRoute);
    context.go('/wardrobe/$dressId/add-booking');
  }
}
