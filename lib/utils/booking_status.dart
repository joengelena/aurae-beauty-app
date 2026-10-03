/// The booking state machine, as the app understands it.
///
/// One definition, deliberately. Before this, every screen carried its own set
/// of status strings — which statuses count as revenue, which still hold their
/// dates, which are finished — and each was an allowlist written against the
/// statuses that existed the day it was written. Adding 'returned' server-side
/// silently made it bookable on the client, because the calendar's list had
/// never heard of it.
///
/// The database has the same single definition in booking_holds_dates(). These
/// two must agree; if you change one, change the other.
class BookingStatus {
  BookingStatus._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String declined = 'declined';
  static const String cancelledByCustomer = 'cancelled_by_customer';
  static const String cancelledByOwner = 'cancelled_by_owner';
  static const String readyForPickup = 'ready_for_pickup';
  static const String readyToShip = 'ready_to_ship';
  static const String collected = 'collected';
  static const String shipped = 'shipped';
  static const String returned = 'returned';
  static const String inspected = 'inspected';
  static const String completed = 'completed';
  static const String completedWithDamage = 'completed_with_damage';

  /// Statuses that release the dates. Everything else holds them.
  static const Set<String> released = {
    declined,
    cancelledByCustomer,
    cancelledByOwner,
  };

  /// Mirrors booking_holds_dates() in DressBookings.sql.
  static bool holdsDates(String status) => !released.contains(status);

  /// The booking is over, one way or another.
  static const Set<String> closed = {
    declined,
    cancelledByCustomer,
    cancelledByOwner,
    completed,
    completedWithDamage,
  };

  static bool isClosed(String status) => closed.contains(status);
  static bool isOpen(String status) => !closed.contains(status);

  /// The dress is physically with the customer.
  static bool isOut(String status) =>
      status == collected || status == shipped;

  /// Money the owner can count on: everything the owner has agreed to and not
  /// since cancelled. Expressed as "not pending, not released" rather than a
  /// list, so a new status in the middle of the flow is counted by default
  /// instead of silently dropping revenue to zero.
  static bool countsAsRevenue(String status) =>
      status != pending && !released.contains(status);

  /// Past its end date and still out. Not the same as "past its dates" — a
  /// booking still at pending or approved is a request nobody answered or a
  /// customer who never turned up, and calling that overdue sends the owner
  /// chasing a dress hanging on her own rail.
  static bool isOverdue(String status, DateTime endDate) {
    if (!isOut(status)) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.isBefore(today);
  }

  static String label(String status) => switch (status) {
        pending => 'Pending',
        approved => 'Approved',
        declined => 'Declined',
        cancelledByCustomer => 'Cancelled by renter',
        cancelledByOwner => 'Cancelled',
        readyForPickup => 'Ready for pickup',
        readyToShip => 'Ready to ship',
        collected => 'Out for rent',
        shipped => 'Shipped',
        returned => 'Returned',
        inspected => 'Inspected',
        completed => 'Completed',
        completedWithDamage => 'Completed · damage',
        _ => status,
      };

  /// What the owner does next, and what the button says.
  ///
  /// Mirrors dress_bookings_enforce_transition() in 99_triggers.sql. A rental
  /// runs the full cycle — out, back, inspected, closed — while a purchase
  /// closes at handover: nothing comes back, so nothing is inspected.
  ///
  /// Only the pickup path is offered from approved: the shipping branch needs a
  /// fulfilment column on the booking to know which way a booking is going, and
  /// a tracking number before it can be marked shipped. A booking that is
  /// already shipped still gets its next step, which the database accepts.
  static String? nextStatus(String status, {String bookingType = 'rental'}) {
    if (bookingType == 'purchase') {
      return switch (status) {
        pending => approved,
        approved => readyForPickup,
        readyForPickup => collected,
        collected || shipped => completed,
        _ => null,
      };
    }
    return switch (status) {
      pending => approved,
      approved => readyForPickup,
      readyForPickup => collected,
      collected || shipped => returned,
      returned => inspected,
      inspected => completed,
      _ => null,
    };
  }

  static String? nextLabel(String status, {String bookingType = 'rental'}) {
    if (bookingType == 'purchase') {
      return switch (status) {
        pending => 'Approve',
        approved => 'Mark ready for pickup',
        readyForPickup => 'Mark collected',
        collected || shipped => 'Complete',
        _ => null,
      };
    }
    return switch (status) {
      pending => 'Approve',
      approved => 'Mark ready for pickup',
      readyForPickup => 'Mark collected',
      collected || shipped => 'Mark returned',
      returned => 'Mark inspected',
      inspected => 'Complete',
      _ => null,
    };
  }

  /// Statuses the owner can still call off, per the transition table: before
  /// the dress has changed hands, for rentals and purchases alike. Once it is
  /// collected or shipped the database refuses any cancellation.
  static const Set<String> ownerCancellable = {
    pending,
    approved,
    readyForPickup,
    readyToShip,
  };

  /// Whether the owner can still call the booking off, and what that is called
  /// at this point in the flow — declining a request and cancelling a booking
  /// she already agreed to are different things to the person receiving them.
  static bool ownerCanCancel(String status) => ownerCancellable.contains(status);

  static String ownerCancelLabel(String status) =>
      status == pending ? 'Decline booking request' : 'Cancel booking';

  static String ownerCancelStatus(String status) =>
      status == pending ? declined : cancelledByOwner;
}
