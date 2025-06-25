import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/home.dart'; // Make sure to import your HomePage
import 'screens/complete_profile.dart'; // Import other screens you need

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaffLink Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define your initial route
      initialRoute: '/',
      // Define all your named routes
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/complete_profile': (context) => const CompleteProfilePage(),
        '/home': (context) => const TaskManagerScreen(), 
      },
      debugShowCheckedModeBanner: false,
    );
  }
}