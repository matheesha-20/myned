import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Screens import කරන්න
import './screens/onboarding_form_screen.dart'; 
import './screens/home_screen.dart'; 
import './screens/loging_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MynedApp());
}

class MynedApp extends StatelessWidget {
  const MynedApp({super.key});

  @override
  Widget build(BuildContext context) {
    // දැනට ලොග් වෙලා ඉන්නවද බලන්න
    User? currentUser = FirebaseAuth.instance.currentUser;

    return GetCupertinoApp(
      title: 'Myned',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFF4500),
        scaffoldBackgroundColor: Color(0xFF020408),
      ),
      // User ඉන්නවා නම් Home, නැත්නම් Login
      initialRoute: currentUser == null ? '/login' : '/home',
      getPages: [
        GetPage(name: '/login', page: () => SignInScreen()),
        GetPage(
          name: '/signup', 
          page: () => MultiStepOnboarding(
            onComplete: () => Get.offAllNamed('/home'), // Register වුණාම Home යනවා
          ),
        ),
        GetPage(name: '/home', page: () => const MynedHome()),
      ],
    );
  }
}