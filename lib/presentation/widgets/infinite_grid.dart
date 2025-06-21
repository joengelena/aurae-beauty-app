import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing_preview.dart';

class InfiniteGrid extends StatefulWidget {
  const InfiniteGrid({super.key});

  @override
  State<InfiniteGrid> createState() => _InfiniteGridState();
}

class _InfiniteGridState extends State<InfiniteGrid> {
  final ScrollController _scrollController = ScrollController();
  final List<int> _items = List.generate(20, (index) => index); // initial items
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _loadMoreItems();
      }
    });
  }

  void _loadMoreItems() async {
    setState(() => _isLoading = true);
    await Future.delayed(
      const Duration(seconds: 2),
    ); // simulate network/API delay

    final nextItems = List.generate(20, (index) => _items.length + index);
    setState(() {
      _items.addAll(nextItems);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount =
        screenWidth > 1000
            ? 4
            : screenWidth > 600
            ? 3
            : 2;
    double previewWidth =
        (MediaQuery.of(context).size.width - (20 * crossAxisCount)) /
        crossAxisCount;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 3, right: 3),
      children: [
        Center(
          child: Wrap(
            spacing: 6,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children:
                _items.map((i) => ListingPreview(width: previewWidth)).toList(),
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
