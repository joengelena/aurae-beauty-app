import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;
  const ImageCarousel({super.key, required this.imageUrls});

  @override
  State<ImageCarousel> createState() => _ImageCarousel();
}

class _ImageCarousel extends State<ImageCarousel> {
  final PageController _controller = PageController();
  bool _hovering = false;

  void _nextPage() {
    if (_controller.page! < widget.imageUrls.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_controller.page! > 0) {
      _controller.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Column(
        spacing: 12,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
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
          SmoothPageIndicator(
            controller: _controller,
            count: widget.imageUrls.length,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Color.fromARGB(148, 0, 0, 0),
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(12),
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
