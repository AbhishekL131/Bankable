import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../components/budget_bar.dart';
import '../firebase_utilities/firebase_auth_methods.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double budget = 0.0;
  double totalExpenses = 0.0;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getBudgetStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('Users').doc(user.uid).snapshots();
    }
    return Stream.empty(); // Empty stream if user is not authenticated
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactionsStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Transactions')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
    return Stream.empty(); // Empty stream if user is not authenticated
  }

  int getRemainingDaysInMonth() {
    final today = DateTime.now();
    final lastDayOfMonth = DateTime(today.year, today.month + 1, 0);
    return lastDayOfMonth.difference(today).inDays;
  }

  double getPerDayRemainingBudget(double remainingBudget) {
    int remainingDays = getRemainingDaysInMonth();
    return remainingDays > 0 ? remainingBudget / remainingDays : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Bankable",
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial', // Custom font for more style (optional)
          ),
        ),
        backgroundColor: Colors.teal.shade400, // Slightly lighter base color for gradient
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.teal.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 5, // Adds slight elevation for a floating effect
        shadowColor: Colors.teal.shade700, // Adding shadow to give depth
      ),


      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getBudgetStream(),
        builder: (context, budgetSnapshot) {
          if (budgetSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (budgetSnapshot.hasError) {
            return Text('Error: ${budgetSnapshot.error}');
          }
          if (!budgetSnapshot.hasData || !budgetSnapshot.data!.exists) {
            return Text('No data found!');
          }

          final userData = budgetSnapshot.data!.data() ?? {};
          budget = userData['Budget']?.toDouble() ?? 0.0;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getTransactionsStream(),
            builder: (context, txSnapshot) {
              if (txSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (txSnapshot.hasError) {
                return Text('Error: ${txSnapshot.error}');
              }

              final transactions = txSnapshot.data?.docs ?? [];
              totalExpenses = transactions
                  .where((doc) => doc['type'] == 'Expense')
                  .fold(0.0, (sum, doc) => sum + (doc['amount'] as num));

              double remainingBudget = budget - totalExpenses;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    _buildBudgetOverviewCard(remainingBudget),
                    SizedBox(height: 10),
                    _buildBudgetProgressBar(remainingBudget),
                    SizedBox(height: 10),
                    _buildRemainingBudgetCard(remainingBudget),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBudgetOverviewCard(double remainingBudget) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.bar_chart, color: Colors.teal, size: 28),
                ),
                SizedBox(width: 12),
                Text(
                  "Budget Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey.shade300, thickness: 1),
            Row(
              children: [
                Expanded(
                  child: _buildHighlightBox(
                    label: "Budget",
                    value: "₹${budget.toStringAsFixed(2)}",
                    icon: Icons.savings,
                    backgroundColor: Colors.teal.shade50,
                    iconColor: Colors.teal.shade800,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildHighlightBox(
                    label: "Expenses",
                    value: "₹${totalExpenses.toStringAsFixed(2)}",
                    icon: Icons.credit_card,
                    backgroundColor: Colors.purple.shade50,
                    iconColor: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: remainingBudget >= 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: remainingBudget >= 0
                      ? Colors.green.shade300
                      : Colors.red.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    remainingBudget >= 0
                        ? Icons.check_circle
                        : Icons.warning_rounded,
                    color: remainingBudget >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Remaining Amount",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: remainingBudget >= 0
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                      Text(
                        "₹${remainingBudget.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: remainingBudget >= 0
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgressBar(double remainingBudget) {
    return Card(
      color: Color(0xFFF4F4F4),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Speedometer on the left
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: BudgetSpeedometer(
                totalExpenses: totalExpenses,
                remainingBudget: remainingBudget,
                budget: budget,
              ),
            ),
            const SizedBox(width: 15),

            // Details inline on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inline Expense Details
                  Row(
                    children: [
                      Icon(Icons.square_rounded, size: 15, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        "${(totalExpenses / budget * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Inline Remaining Details
                  Row(
                    children: [
                      Icon(Icons.square_rounded, size: 15, color: Colors.green),
                      const SizedBox(width: 10),
                      Text(
                        "${(remainingBudget / budget * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Budget Summary Progress Bar
                  Container(
                    height: 9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: LinearProgressIndicator(
                      value: totalExpenses / budget,

                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                ],
              ),
            ),
          ],
        ),
      ),
    );




  }

  Widget _buildRemainingBudgetCard(double remainingBudget) {
    final perDayBudget = getPerDayRemainingBudget(remainingBudget);
    final remainingDays = getRemainingDaysInMonth();

    return Card(
      elevation: 8,
      color: Color(0xFFF4F4F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.date_range, color: Colors.orange, size: 28),
                ),
                SizedBox(width: 12),
                Text(
                  "Budget analysis",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: Colors.grey.shade300, thickness: 1),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildHighlightBox(
                    label: "Days Remaining",
                    value: "$remainingDays days",
                    icon: Icons.timer,
                    backgroundColor: Colors.orange.shade50,
                    iconColor: Colors.orange.shade800,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildHighlightBox(
                    label: "Per Day Budget",
                    value: "₹${perDayBudget.toStringAsFixed(2)}",
                    icon: Icons.monetization_on,
                    backgroundColor: Colors.blue.shade50,
                    iconColor: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightBox({
    required String label,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
