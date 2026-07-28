import 'package:flutter/material.dart';
import 'package:shine_app/data/models/booked_range.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/presentation/widgets/listing/availability_calendar.dart';
import 'package:shine_app/utils/theme.dart';

/// Shared section header for one step of the booking flow (Size, Delivery,
/// Dates, or purchase Availability). Steps read as their own moment through
/// spacing and a label, not a boxed card — the page itself carries the
/// content, no per-section background or shadow.
class BookingStepSection extends StatelessWidget {
  const BookingStepSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeTaupe,
                letterSpacing: 0.4,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

Widget choiceChip({
  required String label,
  required bool selected,
  VoidCallback? onTap,
}) {
  final bg = selected ? themeAccent : Colors.white;
  final fg = selected ? themeText : themeTaupe;
  final border = selected ? themeAccent : themePrimary;

  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: selected ? 0 : 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
      ),
    ),
  );
}

class SizeChoiceCard extends StatelessWidget {
  const SizeChoiceCard({
    super.key,
    required this.listing,
    this.sizeVariants = const [],
    this.isSwitching = false,
    this.onSizeSelected,
  });

  final Listing listing;

  /// Other active listings from the same owner/brand/style. Length 1 means
  /// this dress only comes in one size.
  final List<Listing> sizeVariants;
  final bool isSwitching;
  final ValueChanged<String>? onSizeSelected;

  @override
  Widget build(BuildContext context) {
    final sizes = sizeVariants.length > 1
        ? sizeVariants.map((v) => v.size).toList()
        : [listing.size];
    final single = sizes.length <= 1;

    return BookingStepSection(
      title: 'Size',
      trailing: isSwitching
          ? const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            )
          : null,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: sizes
            .map(
              (size) => choiceChip(
                label: size,
                selected: size == listing.size,
                onTap: (single || isSwitching)
                    ? null
                    : () => onSizeSelected?.call(size),
              ),
            )
            .toList(),
      ),
    );
  }
}

class DeliveryChoiceCard extends StatelessWidget {
  const DeliveryChoiceCard({
    super.key,
    required this.ownerDeliveryOption,
    required this.selected,
    this.onChanged,
  });

  /// The owner's configured delivery option: 'pickup' | 'postal' | 'both'.
  final String? ownerDeliveryOption;
  final String? selected;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final opt = ownerDeliveryOption ?? 'pickup';
    final options = opt == 'both' ? const ['pickup', 'postal'] : [opt];
    final single = options.length <= 1;

    return BookingStepSection(
      title: 'Delivery',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (o) => choiceChip(
                label: o == 'postal' ? 'Postal' : 'Pickup',
                selected: single ? true : selected == o,
                onTap: single ? null : () => onChanged?.call(o),
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookingDatesCard extends StatelessWidget {
  const BookingDatesCard({
    super.key,
    required this.bookings,
    required this.start,
    required this.end,
    this.onDayTapped,
  });

  final List<BookedRange> bookings;
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime>? onDayTapped;

  @override
  Widget build(BuildContext context) {
    return BookingStepSection(
      title: 'Dates',
      child: AvailabilityCalendar(
        bookedRanges: bookings,
        selectionStart: start,
        selectionEnd: end,
        onDayTapped: onDayTapped,
      ),
    );
  }
}
