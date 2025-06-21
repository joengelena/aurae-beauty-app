import 'package:flutter/material.dart';
import 'package:motorix_app/presentation/pages/home.dart';
import 'package:motorix_app/presentation/pages/profile.dart';
import 'package:motorix_app/presentation/pages/watchlist.dart';
import 'package:motorix_app/presentation/widgets/title_app_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentPage = 0;
  final List<Widget> _screens = [HomePage(), WatchlistPage(), ProfilePage()];

  void _onDestinationClick(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppBar(),
      body: Center(
        child: IndexedStack(index: _currentPage, children: _screens),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: SizedBox(
              width: 400,
              child: NavigationBar(
                onDestinationSelected: _onDestinationClick,
                selectedIndex: _currentPage,
                indicatorColor: Colors.grey.shade400,
                backgroundColor: Colors.white,
                height: 70,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.search),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark),
                    label: 'Watchlist',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
