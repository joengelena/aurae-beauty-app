import 'package:flutter/material.dart';
import 'package:shine_app/utils/constants.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  const ImageCarousel({super.key, required this.imageUrls});

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
          color: const Color(0xFFF5EFED),
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
                    return Image.network(
                      widget.imageUrls[index] as String,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF5EFED),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: themeAccent,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF5EFED),
                        child: Center(
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
