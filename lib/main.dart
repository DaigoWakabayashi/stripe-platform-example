import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stripe_platform_example/presentation/navigation/navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StripePlatFormSample',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const NavigationPage(),
    );
  }
}
