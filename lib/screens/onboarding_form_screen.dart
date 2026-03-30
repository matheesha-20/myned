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
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepAccountType(),
                  _stepProfile(),
                  _stepWorkspace(),
                  _stepFinalFinances(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int step) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(4, (i) => Expanded(
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
              children: ["Admin", "Staff"].map((role) => Expanded(
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
    return _buildPageTemplate(
      title: "Quick Start",
      subtitle: "Current status for today",
      nextLabel: "Finish",
      content: Column(
        children: [
          _buildTextField("Initial Income", TextEditingController(), CupertinoIcons.plus_circle, isNum: true),
          const SizedBox(height: 15),
          _buildTextField("Initial Expense", TextEditingController(), CupertinoIcons.minus_circle, isNum: true),
        ],
      ),
      onNext: () => controller.next(onComplete),
      onBack: () => controller.back(),
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
              CupertinoButton.filled(onPressed: onNext, child: Text(nextLabel)),
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

  Widget _buildToggle(String t, bool v, Function(bool) c) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(t, style: const TextStyle(color: Colors.white)), CupertinoSwitch(value: v, activeColor: const Color(0xFFFF4500), onChanged: c)],
  );
}