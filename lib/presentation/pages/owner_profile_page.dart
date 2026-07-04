import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/models/listing.dart';
import 'package:shine_app/data/models/user.dart';
import 'package:shine_app/logic/owner_profile_provider.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:shine_app/utils/utils.dart';
import 'package:provider/provider.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key, required this.userId});

  final String userId;

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  static const double _horizontalPadding = AppConstants.spacingLarge;

  double _itemWidth(double availableWidth, int cols) {
    final spacing = _horizontalPadding * 2 + AppConstants.spacingMedium * (cols - 1);
    return (availableWidth - spacing) / cols;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerProfileProvider>().load(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerProfileProvider>();

    return _buildBody(provider);
  }

  Widget _buildBody(OwnerProfileProvider provider) {
    if (provider.isLoading) return _buildSkeleton();
    if (provider.hasError) return _buildError();
    if (provider.owner == null) return const SizedBox.shrink();
    return _buildContent(provider);
  }

  Widget _buildContent(OwnerProfileProvider provider) {
    final owner = provider.owner!;
    final dresses = provider.dresses;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final cols = availableWidth >= AppConstants.twoColumnBreakpoint ? 2 : 1;
            final cardWidth = _itemWidth(availableWidth, cols);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(owner),
                  Container(height: 1, color: themePrimary.withValues(alpha: 0.6)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _horizontalPadding, 14, _horizontalPadding, 10,
                    ),
                    child: Text(
                      dresses.isEmpty
                          ? 'No dresses listed yet'
                          : '${dresses.length} ${dresses.length == 1 ? "piece" : "pieces"} available',
                      style: TextStyle(
                        fontSize: 13,
                        color: themeTaupe,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (dresses.isEmpty)
                    _buildEmptyState(owner)
                  else
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        _horizontalPadding,
                        0,
                        _horizontalPadding,
                        AppConstants.spacingExtraLarge,
                      ),
                      child: Wrap(
                        spacing: AppConstants.spacingMedium,
                        runSpacing: AppConstants.spacingMedium,
                        children: dresses.map((listing) {
                          return SizedBox(
                            width: cardWidth,
                            child: _ListingCard(listing: listing),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User owner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: themePrimary.withValues(alpha: 0.5),
            backgroundImage: owner.profilePhotoUrl != null
                ? NetworkImage(owner.profilePhotoUrl!)
                : null,
            child: owner.profilePhotoUrl == null
                ? Text(
                    owner.firstName.isNotEmpty
                        ? owner.firstName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: themeText,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            '${owner.firstName} ${owner.lastName}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: themeText,
              letterSpacing: 0.15,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          if (owner.location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: themeTaupe),
                const SizedBox(width: 4),
                Text(owner.location, style: TextStyle(fontSize: 13, color: themeTaupe)),
              ],
            ),
          ],
          if (owner.instagram != null && owner.instagram!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: themeAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '@${owner.instagram}',
                style: TextStyle(
                  fontSize: 12,
                  color: themeText,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(User owner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: themeAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.checkroom_outlined, size: 36, color: themeAccent),
            ),
            const SizedBox(height: 16),
            Text(
              '${owner.firstName} has no public listings yet',
              style: TextStyle(fontSize: 14, color: themeTaupe),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final cols = availableWidth >= AppConstants.twoColumnBreakpoint ? 2 : 1;
            final cardWidth = _itemWidth(availableWidth, cols);
            final cardCount = cols == 2 ? 4 : 3;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: Column(
                      children: [
                        _skeletonCircle(88),
                        const SizedBox(height: 14),
                        _skeletonBox(width: 160, height: 22, radius: 8),
                        const SizedBox(height: 8),
                        _skeletonBox(width: 100, height: 14, radius: 6),
                      ],
                    ),
                  ),
                  Container(height: 1, color: themePrimary.withValues(alpha: 0.6)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _horizontalPadding, 14, _horizontalPadding, 12,
                    ),
                    child: _skeletonBox(width: 120, height: 13, radius: 6),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                    child: Wrap(
                      spacing: AppConstants.spacingMedium,
                      runSpacing: AppConstants.spacingMedium,
                      children: List.generate(cardCount, (_) {
                        return SizedBox(
                          width: cardWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: themePrimary.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: AspectRatio(
                              aspectRatio: AppConstants.listingImageAspectRatio * 0.65,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _skeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: themePrimary.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _skeletonBox({double? width, double height = 16, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: themePrimary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: themeAccent),
            const SizedBox(height: 16),
            Text(
              'Could not load this profile',
              style: TextStyle(
                fontSize: 16,
                color: themeText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              style: TextStyle(fontSize: 13, color: themeTaupe),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<OwnerProfileProvider>().load(widget.userId),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/listings/${listing.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: AppConstants.listingImageAspectRatio,
                child: listing.previewImgUrl.isNotEmpty
                    ? Image.network(
                        listing.previewImgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _photoPlaceholder(),
                      )
                    : _photoPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name ?? listing.brand,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeText,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${listing.brand} · ${listing.style}',
                    style: TextStyle(fontSize: 11, color: themeTaupe, height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _chip(listing.size),
                      if (listing.color != null) _chip(listing.color!),
                      _conditionChip(listing.condition),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.listingType == 'sell'
                        ? formatPrice(listing.pricePerDay)
                        : '${formatPrice(listing.pricePerDay)}/day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: listing.listingType == 'sell'
                          ? const Color(0xFFD4AF37)
                          : themeText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFF5EFED),
      child: Center(
        child: Icon(Icons.checkroom_outlined, color: themeTaupe, size: 40),
      ),
    );
  }

  Widget _chip(String label) {
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
    final Color fg;
    if (lower == 'poor' || lower == 'damaged') {
      bg = themeRose.withValues(alpha: 0.10);
      fg = themeRose;
    } else if (lower == 'fair') {
      bg = themePeach.withValues(alpha: 0.12);
      fg = themePeach;
    } else {
      bg = const Color(0xFFF5EFED);
      fg = themeTaupe;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(condition, style: TextStyle(fontSize: 11, color: fg)),
    );
  }
}
