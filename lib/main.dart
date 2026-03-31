import 'package:flutter/cupertino.dart';
import 'package:get/get.dart'; // Get package එක import කරන්න
import './screens/onboarding_form_screen.dart'; 
import './screens/home_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MynedApp());
}

class MynedApp extends StatefulWidget {
  const MynedApp({super.key});

  @override
  State<MynedApp> createState() => _MynedAppState();
}

class _MynedAppState extends State<MynedApp> {
  bool isSetupComplete = false; 

  @override
  Widget build(BuildContext context) {
    // CupertinoApp වෙනුවට GetCupertinoApp පාවිච්චි කරන්න
    return GetCupertinoApp( 
      title: 'Myned',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFF4500),
        scaffoldBackgroundColor: Color(0xFF020408),
      ),
      home: isSetupComplete 
          ? const MynedHome() 
          : MultiStepOnboarding(
              onComplete: () {
                setState(() {
                  isSetupComplete = true;
                });
              },
            ),
    );
  }
}