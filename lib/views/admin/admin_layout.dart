import 'package:flutter/material.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/views/admin/billing_screen.dart';
import 'package:shop_app/views/admin/product_list_screen.dart';
import 'dashboard_screen.dart';
import 'package:shop_app/views/admin/request_screen.dart';
//import 'package:shop_app/views/admin/billing_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final AuthSession session;
  final Future<void> Function() onLogout;

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int index = 0;

  void changeTab(int i) {
    setState(() {
      index = i;
    });
  }

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      DashboardScreen(
        onNavigate: changeTab,
        session: widget.session,
        onLogout: widget.onLogout,
      ),
      const RequestManagementScreen(),
      AdminProductListScreen(),
      BillingScreen(session: widget.session),
      const _UsersPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x10172B4D),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xff168A62),
          unselectedItemColor: const Color(0xff8491A5),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.space_dashboard_outlined),
              activeIcon: Icon(Icons.space_dashboard_rounded),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt_rounded),
              label: "Requests",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: "Products",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: "Billing",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: "Users",
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersPage extends StatelessWidget {
  const _UsersPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F7FB),
        foregroundColor: const Color(0xff172B4D),
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Users',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF5F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  color: Color(0xff168A62),
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer management',
                style: TextStyle(
                  color: Color(0xff172B4D),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Customer accounts will be available here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff75839A),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
