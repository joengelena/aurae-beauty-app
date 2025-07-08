import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  Widget _buildChip(String label) {
    return FilterChip(label: Text(label), selected: true, onSelected: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            icon: Icon(
              Icons.tune,
              size: 22,
              color: Theme.of(context).primaryColor,
            ),
            label: Text(
              'Filters',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: () {},
          ),
          _buildChip("Used"),
          _buildChip("2WD"),
          _buildChip("Auckland"),
          _buildChip("Toyota"),
        ],
      ),
    );
  }
}
