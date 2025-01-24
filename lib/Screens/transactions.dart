import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  DateTime selectedDate = DateTime.now();  // Stores the selected date

  @override
  void initState() {
    super.initState();
    fetchBudgetAndTransactions();
  }

  void fetchBudgetAndTransactions() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Fetch budget
      final docSnapshot = await _firestore.collection('Users').doc(user.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          budget = docSnapshot.data()?['Budget'] ?? 0.0;
        });
      }

      // Format the selected date to 'yyyy-MM-dd'
      final selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Fetch transactions based on the selected date
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

  // Function to show the date picker
  void _selectDate() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? selectedDate;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;  // Update the selected date
      });
      fetchBudgetAndTransactions();  // Fetch transactions for the selected date
    }
  }

  void showAddTransactionBottomSheet() {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController budgetController = TextEditingController();
    String transactionType = "Expense";

    // Function to handle setting budget
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Transaction or Set Budget",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Budget setting field
              TextField(
                controller: budgetController,
                decoration: InputDecoration(
                  labelText: "Set Budget (Optional)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setBudget();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:  Colors.teal
                ),
                child: Text("Set Budget",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 16),
              // Transaction amount field
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              // Transaction description field
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Dropdown to select Expense/Income
              DropdownButtonFormField<String>(
                value: transactionType,
                items: ["Expense", "Income"]
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    transactionType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Transaction Type",
                  border: OutlineInputBorder(),
                ),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),
              // Add Transaction button
              ElevatedButton(
                onPressed: () async {
                  final user = _auth.currentUser;
                  if (user != null && amountController.text.isNotEmpty) {
                    final double amount = double.parse(amountController.text);

                    // Add income to the budget if the transaction is "Income"
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

                    // Add transaction to the Firestore database
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

                    // Refresh Budget and Transactions
                    fetchBudgetAndTransactions();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.teal
                ),
                child: Text("Add Transaction",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
              ),
            ],
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
                  final Timestamp timestamp = transaction['timestamp'];  // Assuming 'timestamp' is a Firestore Timestamp field
                  final DateTime transactionDate = timestamp.toDate();  // Convert Timestamp to DateTime
                  final String formattedDate = DateFormat('dd MMM yyyy').format(transactionDate); // Formatting date
                  final String formattedTime = DateFormat('h:mm a').format(transactionDate); // Formatting time

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.shade50,
                            Colors.teal.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon Container
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: transaction['type'] == 'Expense'
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              transaction['type'] == 'Expense'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: transaction['type'] == 'Expense'
                                  ? Colors.red
                                  : Colors.green,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction['description'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  transaction['type'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "$formattedDate | $formattedTime",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Amount Display
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                transaction['type'] == 'Expense'
                                    ? "- ₹${(transaction['amount'] ?? 0).toDouble().toStringAsFixed(2)}"
                                    : "+ ₹${(transaction['amount'] ?? 0).toDouble().toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: transaction['type'] == 'Expense'
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );

                },
              ),
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
}
