import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  /// Optional fade-to-color at the bottom edge of the photo, so it blends
  /// into the page background below instead of ending with a hard edge.
  final Color? bottomFadeColor;
  const ImageCarousel({super.key, required this.imageUrls, this.bottomFadeColor});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();
  bool _hovering = false;

  void _nextPage() {
    if (_controller.page! < widget.imageUrls.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_controller.page! > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: AppConstants.listingImageAspectRatio,
        child: Container(
          color: themeSurfaceMuted,
          child: Center(
            child: Icon(Icons.checkroom_outlined, color: themeTaupe, size: 48),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Column(
        spacing: 12,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: AppConstants.listingImageAspectRatio,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return ColoredBox(
                      color: themeSurfaceMuted,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index] as String,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        progressIndicatorBuilder: (context, url, progress) {
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              color: themeAccent,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(
                            Icons.checkroom_outlined,
                            color: themeTaupe,
                            size: 48,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.bottomFadeColor != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.bottomFadeColor!.withValues(alpha: 0),
                          widget.bottomFadeColor!.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_hovering)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: _navButton(Icons.arrow_back_ios, _prevPage),
                ),
              if (_hovering)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: _navButton(Icons.arrow_forward_ios, _nextPage),
                ),
            ],
          ),
          if (widget.imageUrls.length > 1)
            SmoothPageIndicator(
              controller: _controller,
              count: widget.imageUrls.length,
              effect: WormEffect(
                dotHeight: 7,
                dotWidth: 7,
                activeDotColor: themeAccent,
                dotColor: themePrimary,
                spacing: 6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: const Color.fromARGB(148, 0, 0, 0),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
