import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboard_form_controller.dart'; 

class MultiStepOnboarding extends StatelessWidget {
  final VoidCallback onComplete;
  MultiStepOnboarding({super.key, required this.onComplete});

  final controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF020408),
      child: SafeArea(
        child: Column(
          children: [
            Obx(() => _buildProgressBar(controller.currentStep.value)),
            Expanded(
              child: Obx(() => PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepAccountType(), // Index 0
                  _stepProfile(),     // Index 1
                  
                  // Business හෝ Side Hustle තිබේ නම් පමණක් Workspace පියවර එකතු වේ
                  if (controller.mainAccountType.value == "Business" || controller.hasSideHustle.value) 
                    _stepWorkspace(), 

                  _stepFinalFinances(), 
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int step) {
    return Obx(() {
      bool hasWorkspace = controller.mainAccountType.value == "Business" || controller.hasSideHustle.value;
      int dotCount = hasWorkspace ? 4 : 3;

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: List.generate(dotCount, (i) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i <= step ? const Color(0xFFFF4500) : Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
      );
    });
  }

  Widget _stepAccountType() {
    return _buildPageTemplate(
      title: "Choose Path",
      subtitle: "How will you use MYNED?",
      content: Column(
        children: [
          _buildSelectionTile("Personal", "Private expenses", CupertinoIcons.person, "Personal", true),
          const SizedBox(height: 15),
          _buildSelectionTile("Business", "Company finances", CupertinoIcons.briefcase, "Business", true),
          const SizedBox(height: 10),
          Obx(() => controller.mainAccountType.value == "Personal"
            ? _buildToggle("Side Hustle?", controller.hasSideHustle.value, (v) => controller.hasSideHustle.value = v)
            : const SizedBox.shrink()),
        ],
      ),
      onNext: () => controller.next(onComplete),
    );
  }

  Widget _stepProfile() {
    return _buildPageTemplate(
      title: "Set Up Profile",
      subtitle: "Enter your credentials",
      content: Column(
        children: [
          _buildTextField("Full Name", controller.nameController, CupertinoIcons.person),
          const SizedBox(height: 15),
          _buildTextField("Email", controller.emailController, CupertinoIcons.mail),
          const SizedBox(height: 15),
          _buildTextField("Password", controller.passController, CupertinoIcons.lock, isPass: true),
          Obx(() => (controller.mainAccountType.value == "Business" || controller.hasSideHustle.value)
            ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: _buildTextField("Business Name", controller.businessNameController, CupertinoIcons.building_2_fill),
              )
            : const SizedBox.shrink()),
        ],
      ),
      onNext: () => controller.next(onComplete),
      onBack: () => controller.back(),
    );
  }

  Widget _stepWorkspace() {
  return Obx(() {
    String btnLabel = controller.workspaceAction.value == "" ? "Skip" : "Next";
    if (controller.workspaceAction.value == "join") btnLabel = "Join Team";

    return _buildPageTemplate(
      title: "Workspace",
      subtitle: "Collaborate with others",
      nextLabel: btnLabel,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selection Tiles
          if (controller.workspaceAction.value != "join")
            _buildSelectionTile("Create Workspace", "Add members now", CupertinoIcons.add_circled, "create", false),
          
          const SizedBox(height: 15),
          if (controller.workspaceAction.value != "create")
            _buildSelectionTile("Join Workspace", "Use an invite ID", CupertinoIcons.group, "join", false),

          // --- CREATE WORKSPACE SECTION ---
          if (controller.workspaceAction.value == "create") ...[
            const SizedBox(height: 25),
            _buildTextField("Member Email", controller.memberEmailController, CupertinoIcons.mail),
            
            const SizedBox(height: 15),
            const Text("Select Role:", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
            
            // Modern Radio Role Selector
            Row(
              children: ["Admin", "Manager", "Staff"].map((role) => Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedRole.value = role,
                  child: Obx(() => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedRole.value == role ? const Color(0xFFFF4500) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: controller.selectedRole.value == role ? Colors.transparent : Colors.white10),
                    ),
                    child: Center(
                      child: Text(role, style: TextStyle(color: controller.selectedRole.value == role ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                    ),
                  )),
                ),
              )).toList(),
            ),

            const SizedBox(height: 20),

            // --- Permissions Toggle Section ---
            // const Text("Customize Access for this user:", style: TextStyle(color: Colors.white70, fontSize: 13)),
            // const SizedBox(height: 10),
            // Obx(() => Column(
            //   children: controller.permissions.keys.map((key) => Container(
            //     margin: const EdgeInsets.only(bottom: 8),
            //     padding: const EdgeInsets.symmetric(horizontal: 12),
            //     decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(10)),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(key, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            //         CupertinoSwitch(
            //           value: controller.permissions[key]!,
            //           activeColor: const Color(0xFFFF4500),
            //           onChanged: (v) => controller.permissions[key] = v,
            //         ),
            //       ],
            //     ),
            //   )).toList(),
            // )),

            const SizedBox(height: 15),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF4500).withOpacity(0.5)),
                ),
                child: const Center(child: Text("+ Add Member", style: TextStyle(color: Color(0xFFFF4500), fontWeight: FontWeight.bold))),
              ),
              onPressed: () => controller.addMember(),
            ),

            // Added Members List
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.addedMembers.length,
              itemBuilder: (context, index) {
                final member = controller.addedMembers[index];
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['email']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            Text("${member['role']} • ID: ${member['id']}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.doc_on_doc, size: 18, color: Color(0xFFFF4500)),
                        onPressed: () => controller.copyId(member['id']!),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.trash, size: 18, color: Colors.redAccent),
                        onPressed: () => controller.removeMember(index),
                      ),
                    ],
                  ),
                );
              },
            )),
          ],

          // --- JOIN WORKSPACE SECTION ---
          if (controller.workspaceAction.value == "join") ...[
            const SizedBox(height: 25),
            _buildTextField("Workspace Email", controller.emailController, CupertinoIcons.mail),
            const SizedBox(height: 15),
            _buildTextField("Workspace Invite ID", controller.workspaceIdController, CupertinoIcons.number),
          ],
        ],
      ),
      onNext: () => controller.next(onComplete),
      onBack: () => controller.back(),
    );
  });
}

  Widget _stepFinalFinances() {
  return Obx(() {
    bool isSH = controller.hasSideHustle.value;

    return _buildPageTemplate(
      title: "Quick Start",
      subtitle: isSH ? "Set up both your accounts" : "Enter your starting balance",
      nextLabel: "Finish",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSH) ...[
            const Text("Personal Account (Salary, etc.)", style: TextStyle(color: Color(0xFFFF4500), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Personal Currency Picker
            _buildCurrencyPicker("Select Personal Currency", controller.personalCurrency),
            const SizedBox(height: 10),
            _buildTextField("Initial Personal Income", controller.personalIncomeController, CupertinoIcons.money_dollar_circle, isNum: true),
            const SizedBox(height: 10),
            _buildTextField("Initial Personal Expense", controller.personalExpenseController, CupertinoIcons.minus_circle, isNum: true),
            
            const SizedBox(height: 25),
            const Text("Side Hustle Account", style: TextStyle(color: Color(0xFFFF4500), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Side Hustle Currency Picker
            _buildCurrencyPicker("Select Side Hustle Currency", controller.workspaceCurrency),
            const SizedBox(height: 10),
          ] else ...[
             // Business හෝ Personal Only අයට අදාළ Currency එක
             _buildCurrencyPicker("Select Currency", 
                controller.mainAccountType.value == "Business" ? controller.workspaceCurrency : controller.personalCurrency),
             const SizedBox(height: 15),
          ],

          _buildTextField(isSH ? "Initial Side Hustle Income" : "Initial Income", controller.initialIncomeController, CupertinoIcons.plus_circle, isNum: true),
          const SizedBox(height: 15),
          _buildTextField(isSH ? "Initial Side Hustle Expense" : "Initial Expense", controller.initialExpenseController, CupertinoIcons.minus_circle, isNum: true),
        ],
      ),
      onNext: () => controller.next(onComplete),
      onBack: () => controller.back(),
    );
  });
}

// Currency Picker එක සඳහා Helper Widget එක
Widget _buildCurrencyPicker(String label, RxString selectedValue) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
      const SizedBox(height: 5),
      GestureDetector(
        onTap: () {
          showCupertinoModalPopup(
            context: Get.context!,
            builder: (_) => Container(
              height: 250,
              color: const Color(0xFF121212),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: CupertinoPicker(
                      itemExtent: 35,
                      onSelectedItemChanged: (index) => selectedValue.value = controller.currencies[index],
                      children: controller.currencies.map((c) => Center(child: Text(c, style: const TextStyle(color: CupertinoColors.white)))).toList(),
                    ),
                  ),
                  CupertinoButton(child: const Text("Done"), onPressed: () => Get.back()),
                ],
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CupertinoColors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(selectedValue.value, style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold))),
              const Icon(CupertinoIcons.chevron_down, color: CupertinoColors.systemGrey, size: 16),
            ],
          ),
        ),
      ),
    ],
  );
}

  // --- REUSABLE COMPONENTS (Helpers) ---

  Widget _buildPageTemplate({required String title, required String subtitle, required Widget content, VoidCallback? onNext, VoidCallback? onBack, String nextLabel = "Next"}) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 30),
          Expanded(child: SingleChildScrollView(child: content)),
          Row(
            children: [
              if (onBack != null) CupertinoButton(onPressed: onBack, child: const Text("Back", style: TextStyle(color: Colors.white24))),
              const Spacer(),
              CupertinoButton.filled(color: const Color(0xFFFF4500), onPressed: onNext, child: Text(nextLabel)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile(String title, String desc, IconData icon, String val, bool isAccount) {
    return Obx(() {
      bool isSelected = isAccount ? (controller.mainAccountType.value == val) : (controller.workspaceAction.value == val);
      return GestureDetector(
        onTap: () {
          if (isAccount) controller.mainAccountType.value = val;
          else controller.workspaceAction.value = (controller.workspaceAction.value == val) ? "" : val;
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF4500).withOpacity(0.1) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? const Color(0xFFFF4500) : Colors.white10),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFFFF4500) : Colors.white38),
              const SizedBox(width: 15),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ]),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTextField(String hint, TextEditingController ctr, IconData icon, {bool isPass = false, bool isNum = false}) {
    return CupertinoTextField(
      controller: ctr,
      placeholder: hint,
      obscureText: isPass,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      prefix: Padding(padding: const EdgeInsets.only(left: 12), child: Icon(icon, color: Colors.white24, size: 20)),
      padding: const EdgeInsets.all(16),
      style: const TextStyle(color: Colors.white),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
    );
  }


  Widget _buildToggle(String t, bool v, Function(bool) c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const SizedBox(height: 4),
            const Text(
              'Business/Freelancing/Gigs', // මෙතනට ඔයා කැමති නම දාන්න
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        CupertinoSwitch(
          value: v, 
          activeColor: const Color(0xFFFF4500), 
          onChanged: c
        ),
      ],
    ),
  );
}