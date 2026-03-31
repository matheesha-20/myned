import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/onboard_form_controller.dart';

class SignInScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPassController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Sign In"),
        backgroundColor: Color(0xFF020408),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CupertinoColors.white)),
              const SizedBox(height: 30),
              
              CupertinoTextField(
                controller: loginEmailController,
                placeholder: "Email",
                padding: const EdgeInsets.all(15),
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(color: CupertinoColors.systemGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 15),
              
              CupertinoTextField(
                controller: loginPassController,
                placeholder: "Password",
                obscureText: true,
                padding: const EdgeInsets.all(15),
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(color: CupertinoColors.systemGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 30),
              
              CupertinoButton.filled(
                // මෙන්න මෙතනට පාට එකතු කරන්න
                color: const Color(0xFFFF4500), 
                child: const Text("Sign In", style: TextStyle(color: CupertinoColors.white)),
                onPressed: () {
                  controller.signIn(
                    loginEmailController.text, 
                    loginPassController.text, 
                    () => Get.offAllNamed('/home')
                  );
                },
              ),
              
              CupertinoButton(
                child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Color(0xFFFF4500))),
                onPressed: () => Get.toNamed('/signup'), // Onboarding එකට යනවා
              ),
            ],
          ),
        ),
      ),
    );
  }
}