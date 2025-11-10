// import 'package:drive_guard/admin_home_page.dart';
// import 'package:drive_guard/insurance_home_page.dart';
// import 'package:flutter/material.dart';
// import 'login_page.dart'; // Ensure you import the correct file
// import 'package:flutter_settings_screens/flutter_settings_screens.dart';


// void main()  async{
//   await Settings.init(cacheProvider: SharePreferenceCache());
//     FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.presentError(details);
//     // Send to logging service or print
//     print('Flutter error caught: ${details.exception}');
//   };
//   runApp(MyApp());  
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Admin Dashboard',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: LoginPageWidget(), // Correct the reference here
//       // home: AdminHomePage(),
//       // home: InsuranceHomePage(),


//     );
//   }
// }

import 'package:drive_guard/admin_home_page.dart';
import 'package:drive_guard/insurance_home_page.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize settings
  await Settings.init(cacheProvider: SharePreferenceCache());
  
  // Error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter error caught: ${details.exception}');
  };
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with WithForegroundTask to enable foreground service
    return WithForegroundTask(
      child: MaterialApp(
        title: 'Drive Guard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginPageWidget(),
        // home: AdminHomePage(),
        // home: InsuranceHomePage(),
      ),
    );
  }
}