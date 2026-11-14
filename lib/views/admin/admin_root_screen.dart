// import 'package:flutter/material.dart';
// import 'dashboard_screen.dart';
// import 'package:shop_app/views/admin/request_screen.dart';

// class AdminRootScreen extends StatefulWidget {
//   const AdminRootScreen({super.key});

//   @override
//   State<AdminRootScreen> createState() => _AdminRootScreenState();
// }

// class _AdminRootScreenState extends State<AdminRootScreen> {
//   int currentIndex = 0;

//   final List<Widget> pages = const [
//     DashboardScreen(onNavigate: changeTab),
//   RequestManagementScreen(),
//     Center(child: Text("Products")),
//     Center(child: Text("Users")),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[currentIndex],

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: currentIndex,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           setState(() {
//             currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: "Dashboard",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list_alt),
//             label: "Requests",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.inventory_2),
//             label: "Products",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Users",
//           ),
//         ],
//       ),
//     );
//   }
// }
