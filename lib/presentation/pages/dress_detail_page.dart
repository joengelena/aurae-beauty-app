import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/rental_booking.dart';
import 'package:shine_app/logic/back_button_provider.dart';
import 'package:shine_app/logic/dress_detail_provider.dart';
import 'package:shine_app/presentation/widgets/wardrobe/dress_action_menu.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

class DressDetailPage extends StatefulWidget {
  final String dressId;

  const DressDetailPage({super.key, required this.dressId});

  @override
  State<DressDetailPage> createState() => _DressDetailPageState();
}

class _DressDetailPageState extends State<DressDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DressDetailProvider>().loadDress(int.parse(widget.dressId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DressDetailProvider>();
    final dress = provider.dress;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError || dress == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: themeRed),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Dress not found',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadDress(dress.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSmall),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dress.dressPhotoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: AppConstants.listingImageAspectRatio,
                      child: Image.network(
                        dress.dressPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.checkroom_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppConstants.spacingMedium),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dress.internalName != null)
                            Text(
                              dress.internalName!,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            '${dress.brand} · ${dress.style}',
                            style: dress.internalName != null
                                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  )
                                : Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    DressActionMenu(dress: dress, redirectAfterDelete: true),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingSmall),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _chip(context, 'Size: ${dress.size}'),
                    if (dress.color != null) _chip(context, dress.color!),
                    _chip(context, dress.condition),
                    if (dress.purchaseYear != null)
                      _chip(context, 'Purchased ${dress.purchaseYear}'),
                  ],
                ),

                if (dress.notes != null && dress.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  _sectionCard(
                    context,
                    title: 'Notes',
                    children: [
                      Text(dress.notes!, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],

                const SizedBox(height: AppConstants.spacingLarge),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rental Bookings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _handleAddBooking(context, dress.id),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),

                _buildBookingsSection(context, provider, dress.id),

                const SizedBox(height: AppConstants.spacingExtraLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsSection(
    BuildContext context,
    DressDetailProvider provider,
    int dressId,
  ) {
    if (provider.isLoadingBookings) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(Icons.event_available_outlined, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text('No bookings yet', style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _bookingTile(context, provider.bookings[index], dressId);
      },
    );
  }

  Widget _bookingTile(BuildContext context, RentalBooking booking, int dressId) {
    final start = booking.startDate.toIso8601String().substring(0, 10);
    final end = booking.endDate.toIso8601String().substring(0, 10);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(booking.renterName ?? booking.bookingType),
        subtitle: Text('$start → $end'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusChip(context, booking.status),
            IconButton(
              icon: Icon(Icons.delete_outline, color: themeRed, size: 20),
              onPressed: () => _handleDeleteBooking(context, booking, dressId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    final color = switch (status) {
      'confirmed' => Colors.green,
      'active' => Colors.blue,
      'returned' => Colors.grey,
      _ => Colors.orange,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

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
      await context.read<DressDetailProvider>().deleteBooking(booking.id, dressId);
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

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
