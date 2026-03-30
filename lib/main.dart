import 'package:flutter/cupertino.dart';
import './screens/onboarding_form_screen.dart'; // OnboardingForm එක තියෙන file එක
import './screens/home_screen.dart';       // MynedHome එක තියෙන file එක

void main() {
  runApp(const MynedApp());
}

class MynedApp extends StatefulWidget {
  const MynedApp({super.key});

  @override
  State<MynedApp> createState() => _MynedAppState();
}

class _MynedAppState extends State<MynedApp> {
  // ටෙස්ට් කරන්න ලේසි වෙන්න මේ variable එක පාවිච්චි කරමු
  // මේක false නම් Onboarding එක පෙන්වනවා, true නම් කෙලින්ම Home යනවා
  bool isSetupComplete = false; 

  void completeSetup() {
    setState(() {
      isSetupComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Myned',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFF4500),
        scaffoldBackgroundColor: Color(0xFF020408),
      ),
      // මෙතනදී logic එක ක්‍රියාත්මක වෙනවා
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