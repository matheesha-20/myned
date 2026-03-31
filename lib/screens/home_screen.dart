import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:myned/main.dart';

class MynedHome extends StatefulWidget {
  const MynedHome({super.key});

  @override
  State<MynedHome> createState() => _MynedHomeState();
}

class _MynedHomeState extends State<MynedHome> {
  bool isAdvancedMode = false;
  final currentUser = FirebaseAuth.instance.currentUser;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
      Get.snackbar("Success", "Logged out successfully!");
      Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const CupertinoPageScaffold(child: Center(child: Text("Access Denied")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
          return const CupertinoPageScaffold(
            backgroundColor: Color(0xFF020408),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
        String workspaceId = userData['workspaceId'] ?? "";

        return StreamBuilder<DocumentSnapshot>(
          stream: workspaceId.isNotEmpty
              ? FirebaseFirestore.instance.collection('workspaces').doc(workspaceId).snapshots()
              : null,
          builder: (context, wsSnapshot) {
            var wsData = (wsSnapshot.hasData && wsSnapshot.data?.data() != null)
                ? wsSnapshot.data!.data() as Map<String, dynamic>
                : null;

            // දැනට පාවිච්චි කළ යුතු data set එක තෝරා ගැනීම
            final activeData = isAdvancedMode ? wsData : userData;

            return CupertinoPageScaffold(
              backgroundColor: const Color(0xFF020408),
              child: Stack(
                children: [
                  _buildDynamicBackground(),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          child: _buildHeader(userData),
                        ),
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            children: [
                              const SizedBox(height: 10),
                              _buildMainBalanceCard(activeData),
                              const SizedBox(height: 20),
                              _buildQuickStatsRow(activeData),
                              const SizedBox(height: 30),
                              _buildSectionHeader(isAdvancedMode ? "Business Activity" : "Personal Activity"),
                              const SizedBox(height: 15),
                              // මෙහිදී Firestore එකෙන් එන සැබෑ transactions පෙන්වීමට 
                              // වෙනම StreamBuilder එකක් පාවිච්චි කිරීම සුදුසුයි. 
                              // දැනට placeholder එකක් ලෙස පවතී.
                              _buildTransactionList(workspaceId), 
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(bottom: 30, left: 0, right: 0, child: _buildFabMenu(context)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI COMPONENTS (DYNAMIC DATA) ---

  Widget _buildMainBalanceCard(Map<String, dynamic>? data) {
    final bool hasData = data != null;

    // SS වල ඇති Key Names වලට අනුව (personalCurrency / currency)
    String currency = isAdvancedMode 
        ? (data?['currency'] ?? "LKR") 
        : (data?['personalCurrency'] ?? "EUR");
    
    // SS වල ඇති Key Names වලට අනුව (personalBalance / currentBalance)
    double balance = isAdvancedMode 
        ? (data?['currentBalance'] ?? 0).toDouble() 
        : (data?['personalBalance'] ?? 0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2C), Color(0xFF0D1017)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAdvancedMode ? "TOTAL PROFIT" : "AVAILABLE BALANCE",
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text("$currency ${balance.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          _buildMiniProgress(data),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(Map<String, dynamic>? data) {
    String currency = isAdvancedMode 
        ? (data?['currency'] ?? "LKR") 
        : (data?['personalCurrency'] ?? "EUR");

    // SS වල ඇති Key Names (personalIncome, personalExpense / currentincome, currentExpense)
    double inc = isAdvancedMode 
        ? (data?['currentincome'] ?? 0).toDouble() 
        : (data?['personalIncome'] ?? 0).toDouble();
    
    double exp = isAdvancedMode 
        ? (data?['currentExpense'] ?? 0).toDouble() 
        : (data?['personalExpense'] ?? 0).toDouble();

    return Row(
      children: [
        Expanded(child: _buildStatCard("Income", "+$currency ${inc.toInt()}", CupertinoIcons.arrow_up_right, Colors.greenAccent)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard("Expenses", "-$currency ${exp.toInt()}", CupertinoIcons.arrow_down_left, Colors.redAccent)),
      ],
    );
  }

  // --- ADDITION MENU (SCAN, UPLOAD, MANUAL) ---

  Widget _buildFabMenu(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showEntryOptions(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFFFF4500), Color(0xFF932218)]),
            boxShadow: [BoxShadow(color: const Color(0xFFFF4500).withOpacity(0.4), blurRadius: 25)],
          ),
          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showEntryOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Add New Entry"),
        message: const Text("Select how you want to record your transaction"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.camera_viewfinder), SizedBox(width: 10), Text("Scan")]),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.doc), SizedBox(width: 10), Text("Upload")]),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.pencil_ellipsis_rectangle), SizedBox(width: 10), Text("Manual Entry")]),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ),
    );
  }

  // --- HELPER UI METHODS ---

  Widget _buildMiniProgress(Map<String, dynamic>? data) {
    // Income සහ Expense මත පදනම්ව ප්‍රගතිය ගණනය කිරීම
    double inc = isAdvancedMode ? (data?['currentincome'] ?? 1).toDouble() : (data?['personalIncome'] ?? 1).toDouble();
    double exp = isAdvancedMode ? (data?['currentExpense'] ?? 0).toDouble() : (data?['personalExpense'] ?? 0).toDouble();
    
    double progress = (inc > 0) ? (exp / inc) : 0.0;
    if (progress > 1.0) progress = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress, 
            minHeight: 6, 
            backgroundColor: Colors.white10, 
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4500)),
          ),
        ),
        const SizedBox(height: 8),
        Text("${(progress * 100).toInt()}% of income spent", style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("Hello, ${userData['name']?.split(' ')[0] ?? 'User'}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const Text("MYNED", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
        Row(
          children: [
            CupertinoSlidingSegmentedControl<bool>(
              groupValue: isAdvancedMode,
              children: const {
                false: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Personal", style: TextStyle(color: Colors.white, fontSize: 12))),
                true: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Business", style: TextStyle(color: Colors.white, fontSize: 12))),
              },
              onValueChanged: (val) => setState(() => isAdvancedMode = val!),
              thumbColor: const Color(0xFF932218),
              backgroundColor: Colors.white10,
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showProfileMenu(context, userData['name'] ?? "User", userData['role'] ?? "Owner"),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFF4500), width: 1.5)),
                child: const CircleAvatar(radius: 16, backgroundColor: Colors.white10, child: Icon(CupertinoIcons.person_fill, color: Colors.white, size: 18)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList(String workspaceId) {
    // දැනට SS වල Transactions collection එකක් නැති නිසා placeholder එකක් පෙන්වයි.
    // පසුව Firestore query එකක් මගින් මෙය update කළ හැක.
    return Column(
      children: [
        _buildTransactionTile(isAdvancedMode ? "Initial Capital" : "Pocket Money", "+ Success", CupertinoIcons.checkmark_circle_fill),
        _buildTransactionTile("Setup Cost", "- Pending", CupertinoIcons.clock_fill),
      ],
    );
  }

  // --- PREVIOUS UI ELEMENTS (RETAINED) ---

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text("See All", style: TextStyle(color: const Color(0xFFFF4500).withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDynamicBackground() {
    return Stack(
      children: [
        Positioned(top: -100, right: -50, child: CircleAvatar(radius: 150, backgroundColor: const Color(0xFF932218).withOpacity(0.25))),
        Positioned(bottom: 100, left: -50, child: CircleAvatar(radius: 150, backgroundColor: const Color(0xFFFF4500).withOpacity(0.08))),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }

  void _showProfileMenu(BuildContext context, String name, String role) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(name),
        message: Text("Role: $role"),
        actions: [
          CupertinoActionSheetAction(onPressed: () => Navigator.pop(context), child: const Text("Settings")),
          CupertinoActionSheetAction(isDestructiveAction: true, onPressed: _logout, child: const Text("Logout")),
        ],
        cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, IconData icon) {
    bool isCredit = amount.contains('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF4500).withOpacity(0.6), size: 22),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          Text(amount, style: TextStyle(color: isCredit ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}