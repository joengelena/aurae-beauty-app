import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/widgets/profile/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: UserProfile(),
      ),
    );
  }
}
