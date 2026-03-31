import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingController extends GetxController {
  var currentStep = 0.obs;
  final PageController pageController = PageController();

  // Profile Data
  var mainAccountType = "".obs; 
  var hasSideHustle = false.obs;
  var selectedRole = "Admin".obs; 
  var addedMembers = <Map<String, dynamic>>[].obs;
  
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final businessNameController = TextEditingController();

  // Workspace Data
  var workspaceAction = "".obs; 
  final workspaceIdController = TextEditingController();
  final memberEmailController = TextEditingController(); 
  
  // Permissions (Owner/Admin permissions default set කර ඇත)
  var permissions = {
    "Delete Tables": false,
    "Add/Remove Members": false,
    "Edit Past Records": false,
    "Delete Workspace": false,
  }.obs;

  // --- NEW: Regex Validations ---
  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool validateProfile() {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passController.text.isEmpty) {
      _showSnackbar("Error", "Please fill all required profile fields.");
      return false;
    }
    // Email Validation
    if (!isValidEmail(emailController.text.trim())) {
      _showSnackbar("Error", "Please enter a valid email address.");
      return false;
    }
    // Password Validation
    if (passController.text.length < 6) {
      _showSnackbar("Error", "Password must be at least 6 characters.");
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

  // --- NEW: Unique Workspace ID Generator with Firebase Check ---
  Future<String> generateUniqueWorkspaceId() async {
    String prefix = businessNameController.text.length >= 3 
        ? businessNameController.text.substring(0, 3).toUpperCase() 
        : "MYN";
    
    bool isUnique = false;
    String finalId = "";

    while (!isUnique) {
      int randomNum = Random().nextInt(90000) + 10000;
      finalId = "$prefix-$randomNum";

      // Firebase එකේ ID එක දැනටමත් තියෙනවද බලනවා
      var doc = await FirebaseFirestore.instance.collection('workspaces').doc(finalId).get();
      if (!doc.exists) {
        isUnique = true;
      }
    }
    return finalId;
  }

  // --- NEW: Role Based Permissions logic ---
  Map<String, bool> _getPermissionsByRole(String role) {
    switch (role) {
      case "Owner":
      case "Admin":
        return {
          "full_access": true,
          "view_reports": true,
          "add_entry": true,
          "manage_users": true,
          "delete_data": true,
        };
      case "Manager":
        return {
          "full_access": false,
          "view_reports": true,
          "add_entry": true,
          "manage_users": false, 
          "delete_data": false,
        };
      case "Staff":
        return {
          "full_access": false,
          "view_reports": false,
          "add_entry": true, // Bills/Invoices විතරයි
          "manage_users": false,
          "delete_data": false,
        };
      default:
        return {"full_access": false};
    }
  }

  // --- NEW: Firebase Registration Logic ---
  Future<void> registerUser(VoidCallback onSuccess) async {
    try {
      // 1. Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      String uid = userCredential.user!.uid;
      String workspaceId = "";

      // 2. Workspace Handling
      if (workspaceAction.value == "create") {
        workspaceId = await generateUniqueWorkspaceId();
        
        await FirebaseFirestore.instance.collection('workspaces').doc(workspaceId).set({
          'businessName': businessNameController.text.trim(),
          'ownerId': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'members': addedMembers,
        });
      } else {
        workspaceId = workspaceIdController.text.trim();
      }

      // 3. User Profile Saving
      // Register වෙන කෙනා Owner, අනිත් අය Staff/Admin/Manager
      String userRole = (workspaceAction.value == "create") ? "Owner" : "Staff";

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passController.text.trim(), // Requested password field
        'workspaceId': workspaceId,
        'role': userRole,
        'permissions': _getPermissionsByRole(userRole),
        'joinedAt': FieldValue.serverTimestamp(),
      });

      onSuccess();
    } catch (e) {
      _showSnackbar("Registration Error", e.toString());
    }
  }

  void next(VoidCallback onFinalComplete) {
    if (currentStep.value == 0 && mainAccountType.value.isEmpty) {
      _showSnackbar("Error", "Please select an account type.");
      return;
    }

    if (currentStep.value == 1 && !validateProfile()) return;

    bool hasWorkspaceStep = mainAccountType.value == "Business" || hasSideHustle.value;

    if (currentStep.value == 2 && hasWorkspaceStep) {
      if (!validateWorkspace()) return;

      if (workspaceAction.value == "join") {
        registerUser(onFinalComplete); // Join නම් කෙලින්ම register වෙනවා
        return;
      }
    }

    int maxStepIndex = hasWorkspaceStep ? 3 : 2;

    if (currentStep.value < maxStepIndex) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    } else {
      registerUser(onFinalComplete); // Final step එකේදී register වෙනවා
    }
  }

  void addMember() {
    if (memberEmailController.text.isNotEmpty && isValidEmail(memberEmailController.text)) {
      String prefix = businessNameController.text.length >= 3 
          ? businessNameController.text.substring(0, 3).toUpperCase() 
          : "MYN";
      String uniqueId = "$prefix-${Random().nextInt(9000) + 1000}";

      addedMembers.add({
        "email": memberEmailController.text.trim(),
        "role": selectedRole.value,
        "id": uniqueId,
        "permissions": _getPermissionsByRole(selectedRole.value),
      });

      memberEmailController.clear();
    } else {
      _showSnackbar("Error", "Please enter a valid member email.");
    }
  }

  void removeMember(int index) => addedMembers.removeAt(index);

  void copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    _showSnackbar("Copied", "Workspace ID copied to clipboard!");
  }

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

  Future<void> signIn(String email, String password, VoidCallback onSuccess) async {
    try {
      // 1. Firebase Auth හරහා Sign In වීම
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password.trim());

      // 2. සාර්ථක නම් Home Screen එකට යවනවා
      onSuccess();
    } catch (e) {
      _showSnackbar("Login Error", "Invalid email or password. Please try again.");
      print("Login Error: $e");
    }
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