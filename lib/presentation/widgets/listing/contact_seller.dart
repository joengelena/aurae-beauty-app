import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorix_app/logic/listing_detail_provider.dart';
import 'package:motorix_app/utils/feedback_helpers.dart';
import 'package:motorix_app/utils/theme.dart';
import 'package:provider/provider.dart';

class ContactSeller extends StatelessWidget {
  const ContactSeller({super.key});

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<ListingDetailProvider>().listingOwner;

    if (seller == null) {
      return Text('Loading');
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile and Contact Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Avatar and Name
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        seller.profilePhotoUrl != null
                            ? NetworkImage(seller.profilePhotoUrl!)
                            : AssetImage('assets/imgs/default_profile.jpg'),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${seller.firstName} ${seller.lastName}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),

              // Right side - Contact Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phone Number
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: seller.phoneNumber),
                        );
                        FeedbackHelpers.showInfoSnackBar(
                          context,
                          'Phone number copied to clipboard',
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 20, color: themeGreen),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                seller.phoneNumber,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Email
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: seller.email));
                        FeedbackHelpers.showInfoSnackBar(
                          context,
                          'Email copied to clipboard',
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.email, size: 20, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                seller.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
