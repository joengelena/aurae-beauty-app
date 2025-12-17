import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:motorix_app/presentation/widgets/listing/filter_bar.dart';
import 'package:provider/provider.dart';

class SearchAndFiltersBar extends StatefulWidget {
  const SearchAndFiltersBar({super.key});

  @override
  State<SearchAndFiltersBar> createState() => _SearchAndFiltersBarState();
}

class _SearchAndFiltersBarState extends State<SearchAndFiltersBar> {
  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: listingProvider.searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              listingProvider.getNewListings();
            },
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: "What's your next ride?",
              prefixIcon: Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        FilterBar(),

        // Listings Count & Sort Dropdown
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${listingProvider.totalListings} listings",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              DropdownButton<String>(
                value: listingProvider.sortBy.toString(),
                underline: SizedBox(),
                isDense: true,
                style: TextStyle(fontSize: 12, color: Colors.black),
                items:
                    listingProvider.sortByOptions.entries
                        .map<DropdownMenuItem<String>>((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text(entry.key),
                          );
                        })
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    listingProvider.sortBy = value ?? 'uploadDateDesc';
                  });
                  listingProvider.getNewListings();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
