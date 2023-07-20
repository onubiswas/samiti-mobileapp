import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics/mxpanel.dart';
import 'firebase_options.dart';
import 'screens/home/home.dart';
import 'screens/login/loginScreen.dart';
import 'screens/splash/splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin?.initialize(initializationSettings);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs));
}

Future<void> showNotification(String title, String body) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'welcome_notification',
    'Welcome Notification',
    // 'This is to welcome new users to our app',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin?.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}



class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp(this.prefs) {
    initMixpanel();
    final isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      showNotification(
        'Welcome',
        'Welcome to our application!',
      ).then((value) => prefs.setBool('first_time', false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      showNotification(
        'Welcome',
        'Welcome to our application!',
      )
          .then((value) => prefs.setBool('first_time', false));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && isFirstTime) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(notification.title ?? ""),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [Text(notification.body ?? "")],
                ),
              ),
            );
          },
        );
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginForm(prefs),
        '/home': (context) => HomePage(prefs),
      },
    );
  }
}
