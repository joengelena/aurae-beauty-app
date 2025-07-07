import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listings_provider.dart';
import 'package:provider/provider.dart';

class SearchAndFiltersBar extends StatefulWidget {
  const SearchAndFiltersBar({super.key});

  @override
  State<SearchAndFiltersBar> createState() => _SearchAndFiltersBarState();
}

class _SearchAndFiltersBarState extends State<SearchAndFiltersBar> {
  String _selectedSort = 'Sort by';

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: listingProvider.searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              listingProvider.loadMore();
            },
            decoration: InputDecoration(
              hintText: "What's your next ride?",
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 8,
            children: [
              FilterChip(
                label: Text("Filters"),
                avatar: Icon(Icons.tune, size: 18),
                onSelected: (_) {},
              ),
              _buildChip("Used"),
              _buildChip("2WD"),
              _buildChip("Auckland"),
              _buildChip("Toyota"),
            ],
          ),
        ),

        // Listings Count & Sort Dropdown
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "342 listings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedSort,
                underline: SizedBox(),
                items: [
                  DropdownMenuItem(value: "Sort by", child: Text("Sort by")),
                  DropdownMenuItem(value: "Price", child: Text("Price")),
                  DropdownMenuItem(value: "Newest", child: Text("Newest")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSort = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return FilterChip(label: Text(label), selected: true, onSelected: (_) {});
  }
}
