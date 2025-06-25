import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motorix_app/presentation/widgets/scaffold/app_navigation.dart';
import 'package:motorix_app/presentation/widgets/scaffold/title_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const AppScaffold({super.key, required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(currentRoute: state.uri.toString()),
      body: child,
      bottomNavigationBar: AppNavigation(state: state),
    );
  }
}
