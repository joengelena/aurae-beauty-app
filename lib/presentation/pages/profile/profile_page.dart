import 'package:flutter/material.dart';
import 'package:shine_app/logic/week_schedule_provider.dart';
import 'package:shine_app/presentation/widgets/profile/user_profile.dart';
import 'package:shine_app/presentation/widgets/profile/week_schedule_widget.dart';
import 'package:shine_app/utils/theme.dart';
import 'package:provider/provider.dart';

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
      if (mounted) {
        context.read<WeekScheduleProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<WeekScheduleProvider>();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: () => scheduleProvider.load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 24),
              const UserProfile(),
              const SizedBox(height: 24),
              Divider(
                color: themePrimary,
                thickness: 1,
                indent: 32,
                endIndent: 32,
              ),
              const SizedBox(height: 16),
              const WeekScheduleWidget(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
