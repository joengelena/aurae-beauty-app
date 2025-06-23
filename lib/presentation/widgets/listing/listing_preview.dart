import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ListingPreview extends StatelessWidget {
  final double width;

  const ListingPreview({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/listings/1');
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // ensures left alignment
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: width,
                height: width,
                child: Image.network(
                  'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 6),
            Text(
              '2018 Nissan GTR',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Text(
                  'Christchurch',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.speed, size: 16),
                SizedBox(width: 4),
                Text(
                  '109,000 km',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.local_gas_station, size: 16),
                SizedBox(width: 4),
                Text(
                  'Plug-in Hybrid',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16),
                Text('50,450', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
