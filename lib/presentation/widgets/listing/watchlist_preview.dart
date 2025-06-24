import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WatchlistPreview extends StatelessWidget {
  const WatchlistPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/listings/1');
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Positioned(
              top: 3,
              right: 3,
              child: IconButton(
                onPressed: () {
                  // handle delete action
                },
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Right side content
                Expanded(
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Christchurch',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        '2016 Toyota Voxy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.speed, size: 16, color: Colors.black45),
                          SizedBox(width: 4),
                          Text(
                            '107,859 km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.electric_car,
                            size: 16,
                            color: Colors.black45,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hybrid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Ends 20 June',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '\$22,990',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '\$25,990',
                            style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
