// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Awesome Notifications
//   AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'basic_channel',
//         channelName: 'Basic Notifications',
//         channelDescription: 'Notification channel for basic tests',
//         defaultColor: Color(0xFF9D50DD),
//         ledColor: Colors.white,
//         importance: NotificationImportance.High,
//       )
//     ],
//   );

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Awesome Notifications Demo',
//       theme: ThemeData(primarySwatch: Colors.purple),
//       home: NotificationHomePage(),
//     );
//   }
// }

// class NotificationHomePage extends StatefulWidget {
//   @override
//   _NotificationHomePageState createState() => _NotificationHomePageState();
// }

// class _NotificationHomePageState extends State<NotificationHomePage> {
//   @override
//   void initState() {
//     super.initState();
//     requestPermission();
//   }

//   void requestPermission() {
//     AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//       if (!isAllowed) {
//         // Request permission
//         AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//   }

//   void createLocalNotification() {
//     AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 10,
//         channelKey: 'basic_channel',
//         title: 'Hello from Awesome Notifications!',
//         body: 'This is a simple local notification.',
//         notificationLayout: NotificationLayout.Default,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Awesome Notifications Demo')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: createLocalNotification,
//           child: Text('Send Notification'),
//         ),
//       ),
//     );
//   }
// }


import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'push_channel',
        channelName: 'Push Notifications',
        channelDescription: 'Channel for push notifications',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notifications Demo',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: NotificationHomePage(),
    );
  }
}

class NotificationHomePage extends StatefulWidget {
  @override
  _NotificationHomePageState createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  @override
  void initState() {
    super.initState();
    requestPermission();
    setupFirebaseMessagingListeners();
    getFCMToken();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User denied permission');
    }
  }

  void getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  }

  void setupFirebaseMessagingListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AwesomeNotifications().createNotificationFromJsonData(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.data}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Push Notifications Demo')),
      body: Center(
        child: Text('Listening for Push Notifications...'),
      ),
    );
  }
}
