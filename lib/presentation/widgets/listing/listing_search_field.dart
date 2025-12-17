import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listings_provider.dart';

class ListingSearchField extends StatelessWidget {
  final ListingsProvider listingsProvider;

  const ListingSearchField({
    super.key,
    required this.listingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: listingsProvider.searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => listingsProvider.getNewListings(),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: "What's your next ride?",
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: Colors.grey.shade200,
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
