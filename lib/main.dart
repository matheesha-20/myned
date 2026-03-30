import 'package:flutter/cupertino.dart';
import 'screens/home_screen.dart'; // මෙන්න මේක අමතක කරන්න එපා!

void main() {
  runApp(const MynedApp());
}

class MynedApp extends StatelessWidget {
  const MynedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Myned',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFF4500),
      ),

      home: MynedHome(), 
    );
  }
}