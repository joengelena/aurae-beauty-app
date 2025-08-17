import 'package:flutter/material.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:provider/provider.dart';

class ContactSeller extends StatelessWidget {
  const ContactSeller({super.key});

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<ListingDetailProvider>().listingOwner;

    if (seller == null) {
      return Text('Loading');
    }

    return Card(
      color: Colors.grey.shade50,
      elevation: 3,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/imgs/default_profile.jpg'),
            ),
            SizedBox(height: 16),

            // Name
            Text(
              '${seller.firstName} ${seller.lastName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 4),

            // Contact Seller Title + Icons
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Text(
                    'Contact Seller',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.phone, size: 28, color: Colors.green),
                    onPressed: () {
                      // Add call logic
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.email, size: 28, color: Colors.blue),
                    onPressed: () {
                      // Add email logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
