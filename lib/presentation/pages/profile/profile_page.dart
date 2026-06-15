import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shine_app/logic/upcoming_bookings_provider.dart';
import 'package:shine_app/presentation/widgets/profile/upcoming_bookings_widget.dart';
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
      context.read<UpcomingBookingsProvider>().load();
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
            SizedBox(height: 32),
            Divider(color: themePrimary, thickness: 1, indent: 20, endIndent: 20),
            SizedBox(height: 16),
            UpcomingBookingsWidget(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
