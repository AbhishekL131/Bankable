import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Transactions extends StatefulWidget {
  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double budget = 0.0;
  double totalExpenses = 0.0;
  List<Map<String, dynamic>> transactions = [];

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchBudgetAndTransactions();
  }

  void fetchBudgetAndTransactions() async {
    final user = _auth.currentUser;
    if (user != null) {
      final docSnapshot = await _firestore.collection('Users').doc(user.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          budget = docSnapshot.data()?['Budget'] ?? 0.0;
        });
      }

      final selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);

      final querySnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Transactions')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.parse(selectedDateString + ' 00:00:00')))
          .where('timestamp', isLessThan: Timestamp.fromDate(DateTime.parse(selectedDateString + ' 23:59:59')))
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        transactions = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        totalExpenses = transactions
            .where((tx) => tx['type'] == 'Expense')
            .fold(0.0, (sum, tx) => sum + (tx['amount'] as num));
      });
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchBudgetAndTransactions();
    }
  }

  void showAddTransactionBottomSheet() {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController budgetController = TextEditingController();
    String transactionType = "Expense";

    void setBudget() async {
      if (budgetController.text.isNotEmpty) {
        final double newBudget = double.parse(budgetController.text);
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('Users').doc(user.uid).set(
            {'Budget': newBudget},
            SetOptions(merge: true),
          );

          setState(() {
            budget = newBudget;
          });
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal.withOpacity(0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Transaction or Set Budget",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      SizedBox(height: 24),
                      _buildAnimatedTextField(
                        controller: budgetController,
                        label: "Set Budget (Optional)",
                        icon: Icons.account_balance_wallet,
                      ),
                      SizedBox(height: 16),
                      _buildAnimatedButton(
                        onPressed: () {
                          setBudget();
                          Navigator.pop(context);
                        },
                        label: "Set Budget",
                        icon: Icons.save,
                      ),
                      SizedBox(height: 24),
                      _buildAnimatedTextField(
                        controller: amountController,
                        label: "Amount",
                        icon: Icons.attach_money,
                      ),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(
                        controller: descriptionController,
                        label: "Description",
                        icon: Icons.description,
                      ),
                      SizedBox(height: 16),
                      _buildAnimatedDropdown(
                        value: transactionType,
                        items: ["Expense", "Income"],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              transactionType = newValue;
                            });
                          }
                        },
                        icon: Icons.category,
                      ),

                      SizedBox(height: 24),
                      _buildAnimatedButton(
                        onPressed: () async {
                          final user = _auth.currentUser;
                          if (user != null && amountController.text.isNotEmpty) {
                            final double amount = double.parse(amountController.text);
                            if (transactionType == "Income") {
                              final updatedBudget = budget + amount;
                              await _firestore.collection('Users').doc(user.uid).set(
                                {'Budget': updatedBudget},
                                SetOptions(merge: true),
                              );
                              setState(() {
                                budget = updatedBudget;
                              });
                            }

                            await _firestore
                                .collection('Users')
                                .doc(user.uid)
                                .collection('Transactions')
                                .add({
                              'amount': amount,
                              'description': descriptionController.text,
                              'type': transactionType,
                              'timestamp': Timestamp.now(),
                            });

                            fetchBudgetAndTransactions();
                            Navigator.pop(context);
                          }
                        },
                        label: "Add Transaction",
                        icon: Icons.add_circle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Transactions",
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        backgroundColor: Colors.teal.shade400,
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
        elevation: 5,
        shadowColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade600, Colors.teal.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_today, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: transactions.isEmpty
                  ? Center(child: Text("No transactions for the selected date.", style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final Timestamp timestamp = transaction['timestamp'];
                  final DateTime transactionDate = timestamp.toDate();
                  final String formattedDate = DateFormat('dd MMM yyyy').format(transactionDate);
                  final String formattedTime = DateFormat('h:mm a').format(transactionDate);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: AnimatedContainer(

                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [

                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Handle tap
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      transaction['description'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: transaction['type'] == 'Expense'
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        transaction['type'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: transaction['type'] == 'Expense'
                                              ? Colors.red.shade700
                                              : Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  transaction['type'] == 'Expense'
                                      ? "- ₹${(transaction['amount'] ?? 0).toDouble().toStringAsFixed(2)}"
                                      : "+ ₹${(transaction['amount'] ?? 0).toDouble().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: transaction['type'] == 'Expense'
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "$formattedDate | $formattedTime",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )

            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTransactionBottomSheet,
        backgroundColor: Colors.teal,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }



  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.teal.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String transactionType = "Expense";

  Widget _buildAnimatedDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: DropdownButtonFormField<String>(
              value: transactionType, // Use the state variable here
              items: items.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                  setState(() {
                    transactionType = newValue; // Update the state variable
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Transaction Type",
                prefixIcon: Icon(icon, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.teal.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                ),
              ),
              dropdownColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                label,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
