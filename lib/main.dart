import 'package:flutter/material.dart';
import 'package:shop_app/role_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/controllers/udhari_controller.dart';
import 'package:shop_app/controllers/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shop_app/services/local_notification_service.dart';
import 'package:shop_app/services/push_notification_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await PushNotificationService.initialize();

  final festivalDate = DateTime(DateTime.now().year, 11, 8);
  await LocalNotificationService.ensureFestivalReminderSevenDaysBefore(
    festivalName: 'Diwali',
    festivalDate: festivalDate,
    audience: 'user',
  );
  await LocalNotificationService.ensureFestivalReminderSevenDaysBefore(
    festivalName: 'Diwali Offer',
    festivalDate: festivalDate,
    audience: 'admin',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.authController});

  final AuthController? authController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
          lazy: false,
          create: (_) => (authController ?? AuthController())..restoreSession(),
        ),
        ChangeNotifierProvider(create: (_) => UdhariController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: PushNotificationService.navigatorKey,
        scaffoldMessengerKey: PushNotificationService.scaffoldMessengerKey,
        title: 'Kirana Store App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
