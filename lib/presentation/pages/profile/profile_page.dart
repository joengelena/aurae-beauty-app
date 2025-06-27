import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/listing/listing_tile.dart';
import 'package:motorix_app/presentation/widgets/profile/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void showlistingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Options', style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text(
                  'Edit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // handle edit
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text(
                  'Delete',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // handle delete
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: ListView(
          children: [
            SizedBox(height: 24),
            UserProfile(),
            SizedBox(height: 24),
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 32,
              endIndent: 32,
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    'My Listings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListingTile(
                  topRightButtom: IconButton(
                    onPressed: () {
                      showlistingBottomSheet(context);
                    },
                    icon: Icon(Icons.more_vert),
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
