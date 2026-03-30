import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class OnboardingController extends GetxController {
  var currentStep = 0.obs;
  final PageController pageController = PageController();

  // Profile Data
  var mainAccountType = "".obs; 
  var hasSideHustle = false.obs;
  var selectedRole = "Staff".obs; 
  var addedMembers = <Map<String, String>>[].obs;
  
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final businessNameController = TextEditingController();

  // Workspace Data
  var workspaceAction = "".obs; 
  final workspaceIdController = TextEditingController();
  final memberEmailController = TextEditingController(); // Member email එකට අලුත් controller එකක්
  
  // Permissions
  var permissions = {
    "Delete Tables": false,
    "Add/Remove Members": false,
    "Edit Past Records": false,
    "Delete Workspace": false,
  }.obs;

  bool validateProfile() {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passController.text.isEmpty) {
      _showSnackbar("Error", "Please fill all required profile fields.");
      return false;
    }
    if ((mainAccountType.value == "Business" || hasSideHustle.value) && businessNameController.text.isEmpty) {
      _showSnackbar("Error", "Business name is required.");
      return false;
    }
    return true;
  }

  bool validateWorkspace() {
    if (workspaceAction.value == "join" && workspaceIdController.text.isEmpty) {
      _showSnackbar("Error", "Please enter a valid Workspace ID.");
      return false;
    }
    return true;
  }

  // UI එකේ නමට (next) ගැලපෙන්න හැදුවා
  void next(VoidCallback onFinalComplete) {
    if (currentStep.value == 1 && !validateProfile()) return;
    if (currentStep.value == 2 && !validateWorkspace()) return;

    if (currentStep.value < 3) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    } else {
      onFinalComplete(); 
    }
  }

  void addMember() {
  if (memberEmailController.text.isNotEmpty) {
    // Business Name එකෙන් මුල් අකුරු 3ක් අරගෙන Unique ID එකක් හදනවා
    String prefix = businessNameController.text.length >= 3 
        ? businessNameController.text.substring(0, 3).toUpperCase() 
        : "MYN";
    String uniqueId = "$prefix-${Random().nextInt(9000) + 1000}";

    addedMembers.add({
      "email": memberEmailController.text,
      "role": selectedRole.value,
      "id": uniqueId,
    });

    memberEmailController.clear(); // Email field එක clear කරනවා
  } else {
    _showSnackbar("Error", "Please enter a member email.");
  }
}

void removeMember(int index) => addedMembers.removeAt(index);

void copyId(String id) {
  Clipboard.setData(ClipboardData(text: id));
  _showSnackbar("Copied", "Workspace ID copied to clipboard!");
}

  // UI එකේ නමට (back) ගැලපෙන්න හැදුවා
  void back() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF4500).withOpacity(0.8),
      colorText: CupertinoColors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    businessNameController.dispose();
    workspaceIdController.dispose();
    memberEmailController.dispose();
    super.onClose();
  }
}