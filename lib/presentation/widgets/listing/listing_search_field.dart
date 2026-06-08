import 'package:flutter/material.dart';
import 'package:shine_app/logic/listings_provider.dart';

class ListingSearchField extends StatefulWidget {
  final ListingsProvider listingsProvider;

  const ListingSearchField({
    super.key,
    required this.listingsProvider,
  });

  @override
  State<ListingSearchField> createState() => _ListingSearchFieldState();
}

class _ListingSearchFieldState extends State<ListingSearchField> {
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _hasInput = widget.listingsProvider.searchController.text.isNotEmpty;
    widget.listingsProvider.searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.listingsProvider.searchController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.listingsProvider.searchController.text.isNotEmpty;
    if (hasText != _hasInput) {
      setState(() {
        _hasInput = hasText;
      });
    }
  }

  void _handleSearch() {
    widget.listingsProvider.getNewListings();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.listingsProvider.searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _handleSearch(),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search styles, brands, or sizes',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
          child: FilledButton(
            onPressed: _hasInput ? _handleSearch : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(60, 28),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Search',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF0E9E6),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
