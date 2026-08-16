import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/my_bookings_provider.dart';
import 'package:shine_app/presentation/widgets/profile/account_menu.dart';
import 'package:shine_app/presentation/widgets/profile/active_profile_card.dart';
import 'package:shine_app/presentation/widgets/profile/my_bookings_preview_card.dart';
import 'package:shine_app/presentation/widgets/profile/user_profile.dart';
import 'package:shine_app/utils/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyBookingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          children: [
            SizedBox(height: 24),
            UserProfile(),
            SizedBox(height: 28),
            MyBookingsPreviewCard(),
            SizedBox(height: 16),
            Divider(color: themePrimary, thickness: 1, indent: 20, endIndent: 20),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ActiveProfileCard(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AccountMenu(),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
