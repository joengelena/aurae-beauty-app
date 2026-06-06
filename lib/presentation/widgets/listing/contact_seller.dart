import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shine_app/logic/listing_detail_provider.dart';
import 'package:shine_app/utils/feedback_helpers.dart';
import 'package:shine_app/utils/theme.dart';
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themePrimary.withValues(alpha: 0.8),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: seller.profilePhotoUrl != null
                      ? NetworkImage(seller.profilePhotoUrl!)
                      : AssetImage('assets/imgs/default_profile.jpg'),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${seller.firstName} ${seller.lastName}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: themeText,
                      ),
                    ),
                    Text(
                      'Owner',
                      style: TextStyle(fontSize: 12, color: themeTaupe),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 14),
            Divider(height: 1, color: Color(0xFFEEE8E4)),
            SizedBox(height: 12),

            // Phone
            _ContactRow(
              icon: Icons.phone_outlined,
              label: seller.phoneNumber,
              iconColor: themeSage,
              onTap: () {
                Clipboard.setData(ClipboardData(text: seller.phoneNumber));
                FeedbackHelpers.showInfoSnackBar(
                  context,
                  'Phone number copied to clipboard',
                );
              },
            ),
            SizedBox(height: 10),

            // Email
            _ContactRow(
              icon: Icons.mail_outline,
              label: seller.email,
              iconColor: themeTaupe,
              onTap: () {
                Clipboard.setData(ClipboardData(text: seller.email));
                FeedbackHelpers.showInfoSnackBar(
                  context,
                  'Email copied to clipboard',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: themeText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.copy_outlined, size: 14, color: themeTaupe),
        ],
      ),
    );
  }
}
