import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/data/exceptions/app_exception.dart';
import 'package:shine_app/data/models/upcoming_booking.dart';
import 'package:shine_app/logic/my_bookings_provider.dart';
import 'package:shine_app/presentation/widgets/common/app_empty_state.dart';
import 'package:shine_app/presentation/widgets/profile/booking_list_card.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool _showPast = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<MyBookingsProvider>().load();
    });
  }

  Future<void> _handleCancel(UpcomingBooking booking) async {
    final confirmed = await FeedbackHelpers.showConfirmation(
      context,
      title: 'Cancel this booking?',
      message:
          '${dressLabel(booking)}, ${_shortRange(booking)}. This can\'t be undone.',
      confirmButtonText: 'Cancel booking',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<MyBookingsProvider>().cancel(booking.id);
      if (!mounted) return;
      FeedbackHelpers.showSuccessSnackBar(context, 'Booking cancelled');
    } catch (e) {
      if (!mounted) return;
      final message =
          e is AppException ? e.message : 'Failed to cancel booking';
      FeedbackHelpers.showErrorSnackBar(context, message);
    }
  }

  String _shortRange(UpcomingBooking booking) =>
      '${booking.startDate.day}/${booking.startDate.month} – '
      '${booking.endDate.day}/${booking.endDate.month}';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.contentMaxWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'My Bookings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildToggle(),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Consumer<MyBookingsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.hasError) {
                    return AppEmptyState(
                      icon: Icons.error_outline,
                      title: 'Something went wrong',
                      body: provider.errorMessage,
                      action: FilledButton(
                        onPressed: () => provider.load(),
                        child: const Text('Try again'),
                      ),
                    );
                  }

                  final bookings =
                      _showPast ? provider.past : provider.upcoming;

                  if (bookings.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.checkroom_outlined,
                      title:
                          _showPast
                              ? 'No history bookings'
                              : 'No upcoming bookings',
                      body:
                          _showPast
                              ? 'Bookings that have finished or been cancelled will show up here.'
                              : 'When you book a dress, it will show up here with its dates and status.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return BookingListCard(
                        booking: booking,
                        showCancel: !_showPast && isBookingCancellable(booking),
                        onCancel: () => _handleCancel(booking),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: themeSurfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _toggleButton(
            'Upcoming',
            !_showPast,
            () => setState(() => _showPast = false),
          ),
          _toggleButton(
            'History',
            _showPast,
            () => setState(() => _showPast = true),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? themeText : themeTaupe,
            ),
          ),
        ),
      ),
    );
  }
}
