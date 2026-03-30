import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MynedHome extends StatefulWidget {
  const MynedHome({super.key});

  @override
  State<MynedHome> createState() => _MynedHomeState();
}

class _MynedHomeState extends State<MynedHome> {
  bool isAdvancedMode = false;
  String businessWorkspaceID = "MYNED-CORP-001";

  // Action Sheet එක පෙන්වන Function එක (Camera/Doc Options)
  void _showAddOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Add New Transaction"),
        message: const Text("Select a method to import data from your bills"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // මෙතනදී Camera Scan Screen එකට යන්න පුළුවන්
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera_viewfinder, color: Color(0xFFFF4500)),
                SizedBox(width: 10),
                Text("Scan Bill (AI OCR)", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // මෙතනදී File Picker එකක් දාන්න පුළුවන්
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.doc_text_fill, color: Color(0xFFFF4500)),
                SizedBox(width: 10),
                Text("Upload PDF / Excel", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Manual Entry", style: TextStyle(color: Colors.white70)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF020408),
      child: Stack(
        children: [
          _buildDynamicBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildGlassCard(
                    child: isAdvancedMode ? _buildBusinessDashboard() : _buildPersonalDashboard(),
                  ),
                  const SizedBox(height: 35),
                  _buildSectionTitle(),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ...(isAdvancedMode ? _getBusinessTransactions() : _getPersonalTransactions()),
                        // ප්‍රධානම දේ: Button එකට යට නොවෙන්න මෙතන ඉඩ තියන්න
                        const SizedBox(height: 120), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Bottom Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildBottomFab(),
          ),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("MYNED", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text(isAdvancedMode ? "Shared Workspace" : "Personal Space", style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        CupertinoSlidingSegmentedControl<bool>(
          groupValue: isAdvancedMode,
          children: const {
            false: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Personal", style: TextStyle(color: Colors.white, fontSize: 13))),
            true: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Business", style: TextStyle(color: Colors.white, fontSize: 13))),
          },
          onValueChanged: (val) => setState(() => isAdvancedMode = val!),
          backgroundColor: Colors.white.withOpacity(0.05),
          thumbColor: const Color(0xFF932218),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isAdvancedMode ? "Business Activity" : "Personal Activity", 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        if (isAdvancedMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFF4500).withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(businessWorkspaceID, style: const TextStyle(color: Color(0xFFFF4500), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildPersonalDashboard() {
    return Column(
      children: [
        const Text("MY REMAINING BALANCE", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        const Text("LKR 42,500.00", style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
        const SizedBox(height: 25),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildBusinessDashboard() {
    return Column(
      children: [
        const Text("BUSINESS NET PROFIT", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        const Text("LKR 850,250.00", style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem("Total Sales", "LKR 1.2M"),
            Container(width: 1, height: 20, color: Colors.white10),
            _buildStatItem("Payables", "LKR 350k"),
          ],
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildTransactionTile(String title, String amt, String cat, bool isExpense, IconData icon, String userTag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04), 
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF4500).withOpacity(0.7), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("$cat • $userTag", style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ]),
          ),
          Text(amt, style: TextStyle(color: isExpense ? Colors.redAccent : Colors.greenAccent, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildBottomFab() {
    return Center(
      child: GestureDetector(
        onTap: () => _showAddOptions(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFFFF4500), Color(0xFF932218)]),
            boxShadow: [BoxShadow(color: const Color(0xFFFF4500).withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
          ),
          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDynamicBackground() {
    return Stack(
      children: [
        Positioned(top: -120, right: -60, child: _buildBlurCircle(const Color(0xFF932218).withOpacity(0.35), 280)),
        Positioned(bottom: 50, left: -80, child: _buildBlurCircle(const Color(0xFFFF4500).withOpacity(0.1), 320)),
      ],
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildProgressIndicator() {
    return Column(children: [
      ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0.4, minHeight: 6, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(Color(0xFFFF4500)))),
      const SizedBox(height: 10),
      const Text("40% of budget spent", style: TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }

  List<Widget> _getPersonalTransactions() => [
    _buildTransactionTile("Dinner", "-1,200.00", "Food", true, CupertinoIcons.cart, "Self"),
    _buildTransactionTile("Online Order", "-3,500.00", "Shopping", true, CupertinoIcons.bag, "Self"),
  ];

  List<Widget> _getBusinessTransactions() => [
    _buildTransactionTile("Supplier A", "-25,000.00", "Stock", true, CupertinoIcons.cube_box, "Admin"),
    _buildTransactionTile("Sales Income", "+15,000.00", "Revenue", false, CupertinoIcons.money_dollar, "Nimal"),
  ];
}