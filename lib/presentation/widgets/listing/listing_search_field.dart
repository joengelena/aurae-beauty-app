import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shine_app/logic/listings_provider.dart';

class ListingSearchField extends StatefulWidget {
  final ListingsProvider listingsProvider;

  const ListingSearchField({super.key, required this.listingsProvider});

  @override
  State<ListingSearchField> createState() => _ListingSearchFieldState();
}

class _ListingSearchFieldState extends State<ListingSearchField> {
  bool _hasInput = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _hasInput = widget.listingsProvider.searchController.text.isNotEmpty;
    widget.listingsProvider.searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.listingsProvider.searchController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.listingsProvider.searchController.text.isNotEmpty;
    if (hasText != _hasInput) setState(() => _hasInput = hasText);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.listingsProvider.getNewListings();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    widget.listingsProvider.searchController.clear();
    widget.listingsProvider.getNewListings();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.listingsProvider.searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) {
        _debounce?.cancel();
        widget.listingsProvider.getNewListings();
      },
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search by name or brand',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _hasInput
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: _clearSearch,
                splashRadius: 16,
              )
            : null,
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
