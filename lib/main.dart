import 'package:flutter/material.dart';
import 'package:persistent_bottombar/page1.dart';
import 'package:persistent_bottombar/page2.dart';
import 'package:persistent_bottombar/page3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: createColor(const Color(0xFF0D65D8)),
      ),
      home: const PersistentScreen(),
    );
  }
}

MaterialColor createColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class PersistentTabItem {
  final ScrollController? scrollController;
  final Widget tab;
  final String label;
  final Widget icon;
  final IconData? activeIcon;
  PersistentTabItem({
    this.scrollController,
    required this.tab,
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

class PersistentScreen extends StatelessWidget {
  const PersistentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        PersistentTabItem(
          tab: const TabPage1(),
          icon: const Icon(Icons.home_outlined),
          activeIcon: Icons.home_rounded,
          label: "Home",
        ),
        PersistentTabItem(
          tab: const TabPage2(),
          icon: const Icon(Icons.search_outlined),
          activeIcon: Icons.search_rounded,
          label: "Search",
        ),
        PersistentTabItem(
          tab: const TabPage3(),
          icon: const Icon(Icons.grid_view_outlined),
          activeIcon: Icons.grid_view_rounded,
          label: "Create",
        ),
        PersistentTabItem(
          tab: const TabPage2(),
          icon: const Icon(Icons.notifications_outlined),
          activeIcon: Icons.notifications_rounded,
          label: "Notification",
        ),
        PersistentTabItem(
          tab: const TabPage1(),
          icon: const Icon(Icons.person_outline),
          activeIcon: Icons.person_rounded,
          label: "Home",
        ),
      ],
    );
  }
}

class PersistentBottomBarScaffold extends StatefulWidget {
  const PersistentBottomBarScaffold({
    super.key,
    this.m3Design = false,
    this.m3LabelBehavior,
    this.type,
    this.showSelectedLabels,
    this.showUnselectedLabels,
    required this.items,
  }) : assert(items.length >= 2);
  final bool m3Design;
  final NavigationDestinationLabelBehavior? m3LabelBehavior;
  // m3Design true ise bu özelliğe gerek yok
  final BottomNavigationBarType? type;
  final List<PersistentTabItem> items;
  final bool? showSelectedLabels;
  final bool? showUnselectedLabels;
  @override
  State<PersistentBottomBarScaffold> createState() =>
      _PersistentBottomBarScaffoldState();
}

class _PersistentBottomBarScaffoldState
    extends State<PersistentBottomBarScaffold> {
  int _selectedTab = 0;

  List<int> clickTabList = List.filled(2, 0);

  late List<GlobalKey<NavigatorState>?> _tabKeys;

  @override
  void initState() {
    super.initState();

    keysAdd();
  }

  Future<void> keysAdd() async {
    //sayfaların hepsi ilk başta yüklenmesin diye keyleri null veriyoruz
    //bundan dolayıda body kısmında [Navigator] görünmeden [_CircularPage]
    //sayfası gösterilir.
    _tabKeys = List.filled(widget.items.length, null);
    _tabKeys.first = GlobalKey<NavigatorState>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Sekem kontrolü açık olan sekmede geri tuşuna basılınca
        // ilgili NavigtorKey kullanılır.
        if (_tabKeys[_selectedTab]!.currentState?.canPop() ?? false) {
          _tabKeys[_selectedTab]?.currentState?.pop();
          return false;
        } else {
          // Kök Navigator kullanır
          return true;
        }
      },
      child: Scaffold(
          // Açılan sekme durumunu koruyabilmek için indexedStack kullanıldı.
          body: IndexedStack(
            index: _selectedTab,
            children: List.generate(
                _tabKeys.length,
                (index) => _tabKeys[index] == null
                    ? const _CircularPage()
                    : Navigator(
                        key: _tabKeys[index],
                        onGenerateInitialRoutes: (navigator, initialRoute) => [
                          MaterialPageRoute(
                              builder: (context) => widget.items[index].tab),
                        ],
                      )).toList(),
          ),

          // Sabit kalacak BottomNavigationBar Material 3 tasarımı ya da
          // standart BottomNavigationBar tasarımı.
          bottomNavigationBar: widget.m3Design
              ? NavigationBar(
                  animationDuration: const Duration(seconds: 1),
                  selectedIndex: _selectedTab,
                  labelBehavior: widget.m3LabelBehavior,
                  onDestinationSelected: (index) => bottomButtonOnTap(index),
                  destinations: widget.items
                      .map((item) => NavigationDestination(
                            icon: item.icon,
                            selectedIcon: Icon(item.activeIcon),
                            tooltip: item.label,
                            label: item.label,
                          ))
                      .toList(),
                )
              : BottomNavigationBar(
                  currentIndex: _selectedTab,
                  showSelectedLabels: widget.showSelectedLabels,
                  showUnselectedLabels: widget.showUnselectedLabels,
                  type: widget.type,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Colors.grey,
                  onTap: (index) => bottomButtonOnTap(index),
                  items: widget.items
                      .map(
                        (item) => BottomNavigationBarItem(
                          icon: item.icon,
                          activeIcon: Icon(item.activeIcon),
                          tooltip: item.label,
                          label: item.label,
                        ),
                      )
                      .toList(),
                )),
    );
  }

  void bottomButtonOnTap(int index) {
    return setState(
      () {
        _selectedTab = index;
        //ilk basmada sayfayı yükler.
        loadTabKey(index);

        // clickTabList sekme indexi tutulur buna göre sekem butonuna
        //ikinci kez basılıp basılmadığı kontrol edilir
        clickTabList.last = clickTabList.first;
        clickTabList.first = _selectedTab;

        // Eğer aynı tab butonuna ikinci kez basılırsa sekmenin
        // navigatorunun ana ekranına geri döndürür.
        if (clickTabList.first == clickTabList.last) {
          if (widget.items[index].scrollController != null &&
              !_tabKeys[index]!.currentState!.canPop()) {
            widget.items[index].scrollController?.position.animateTo(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          }

          _tabKeys[index]?.currentState?.popUntil(
                (route) => route.isFirst,
              );
        }
      },
    );
  }

  void loadTabKey(index) {
    if (_tabKeys[index] == null) {
      _tabKeys[index] = GlobalKey<NavigatorState>();
    }
  }
}

class _CircularPage extends StatefulWidget {
  const _CircularPage({Key? key}) : super(key: key);

  @override
  State<_CircularPage> createState() => __CircularPageState();
}

class __CircularPageState extends State<_CircularPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
