import 'package:binchat/screens/chat.dart';
import 'package:binchat/screens/settings.dart';
import 'package:binchat/utils/splash_screen.dart';
import 'package:binchat/screens/learn.dart';
import 'package:binchat/screens/explore.dart';
import 'package:flutter/material.dart';
import 'package:binchat/themes/theme.dart';
import 'package:binchat/screens/home.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BinChat',
        debugShowCheckedModeBanner:
            false, // remove debug flag in the device emulator
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.light,
        home: const SplashScreen());
  }
}

class PersistenBottomNavBar extends StatelessWidget {
  PersistenBottomNavBar({super.key});
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 2);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _controller,
      tabs: [
        PersistentTabConfig(
          screen: const HomePage(),
          item: ItemConfig(
              icon: const Icon(Icons.home),
              title: "Home",
              activeForegroundColor: Colors.black),
        ),
        PersistentTabConfig(
          screen: FeedPage(),
          item: ItemConfig(
              icon: const Icon(Icons.explore),
              title: "Explore",
              activeForegroundColor: Colors.black),
        ),
        PersistentTabConfig(
          screen: const ChatScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.chat_rounded),
            title: "Chat",
            activeForegroundColor: Colors.black,
            // inactiveForegroundColor: Theme.of(context).primaryColor.withOpacity(0.2)
            // inactiveBackgroundColor: Colors.black
          ),
        ),
        PersistentTabConfig(
          screen: const Learn(),
          item: ItemConfig(
              icon: const Icon(Icons.tips_and_updates),
              title: "Learn",
              activeForegroundColor: Colors.black),
        ),
        PersistentTabConfig(
          screen: const SettingsScreen(),
          item: ItemConfig(
              icon: const Icon(Icons.settings),
              title: "Settings",
              activeForegroundColor: Colors.black),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style13BottomNavBar(
        navBarConfig: navBarConfig,
      ),
    );
  }
}
