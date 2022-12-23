import 'dart:developer';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class PersistentTabItem {
  final Widget tab;
  final GlobalKey<NavigatorState> navigatorKey;
  final String title;
  final IconData icon;
  PersistentTabItem({
    required this.tab,
    required this.navigatorKey,
    required this.title,
    required this.icon,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PersistentScreen(),
    );
  }
}

class PersistentScreen extends StatelessWidget {
  final _tab1Key = GlobalKey<NavigatorState>();
  final _tab2Key = GlobalKey<NavigatorState>();
  final _tab3Key = GlobalKey<NavigatorState>();

  PersistentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(items: [
      PersistentTabItem(
        tab: const TabPage1(),
        navigatorKey: _tab1Key,
        title: "Home",
        icon: Icons.home,
      ),
      PersistentTabItem(
        tab: const TabPage2(),
        navigatorKey: _tab2Key,
        title: "Bookmarks",
        icon: Icons.bookmark,
      ),
      PersistentTabItem(
        tab: const TabPage3(),
        navigatorKey: _tab3Key,
        title: "Profile",
        icon: Icons.person,
      )
    ]);
  }
}

class PersistentBottomBarScaffold extends StatefulWidget {
  const PersistentBottomBarScaffold({
    super.key,
    required this.items,
  });
  final List<PersistentTabItem> items;
  @override
  State<PersistentBottomBarScaffold> createState() =>
      _PersistentBottomBarScaffoldState();
}

class _PersistentBottomBarScaffoldState
    extends State<PersistentBottomBarScaffold> {
  int _selectedTab = 0;

  List<int> clickTabList = List.filled(2, 0);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Sekem kontrolü açık olan sekmede geri tuşuna basılınca
        // ilgili NavigtorKey kullanılır.
        if (widget.items[_selectedTab].navigatorKey.currentState?.canPop() ??
            false) {
          widget.items[_selectedTab].navigatorKey.currentState?.pop();
          return false;
        } else {
          // Kök Navigatorü kullanır
          return true;
        }
      },
      child: Scaffold(
        // Açılan sekme durumunu koruyabilmek için indexedStack kullanıldı.
        body: IndexedStack(
          index: _selectedTab,
          children: widget.items
              // Her sekme için ayrı bir Navigator oluşturulur böylelikle
              // sekmelerde birbirinden bağımsız şekilde gezilebilir.
              .map((page) => Navigator(
                    key: page.navigatorKey,
                    onGenerateInitialRoutes: (navigator, initialRoute) => [
                      MaterialPageRoute(builder: (context) => page.tab),
                    ],
                  ))
              .toList(),
        ),

        // Sabit kalacak BottomNavigationBar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (index) => setState(() {
            inspect(widget.items[index].navigatorKey);
            _selectedTab = index;

            // clickTabList sekme indexi tutulur buna göre sekem butonuna
            //ikinci kez basılıp basılmadığı kontrol edilir
            clickTabList.last = clickTabList.first;
            clickTabList.first = _selectedTab;
            // Eğer aynı tab butonuna ikinci kez basılırsa sekmenin
            // navigatorunun ana ekranına geri döndürür.
            if (clickTabList.first == clickTabList.last) {
              widget.items[index].navigatorKey.currentState?.popUntil(
                (route) => route.isFirst,
              );
            }
          }),
          items: widget.items
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.title,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class TabPage1 extends StatelessWidget {
  const TabPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tab Page 1")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Tab 1"),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Page1(),
                  ),
                );
              },
              child: const Text("Got to Page1"),
            )
          ],
        ),
      ),
    );
  }
}

class TabPage2 extends StatelessWidget {
  const TabPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tab Page 2")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Tab 2"),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Page2(),
                ),
              ),
              child: const Text("Got to Page2"),
            )
          ],
        ),
      ),
    );
  }
}

class TabPage3 extends StatelessWidget {
  const TabPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tab Page 3")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Tab 3"),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Page3(),
                  ),
                );
              },
              child: const Text("Got to Page3"),
            )
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page1"),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page2"),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page3"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
