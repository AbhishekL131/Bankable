import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class Reports extends StatefulWidget {
  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final Gemini _gemini = Gemini.instance;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _fetchUserTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('transactions')
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  void _sendMessage(String message) async {
    setState(() {
      _chatHistory.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    try {
      final transactions = await _fetchUserTransactions();
      final transactionData = transactions.map((t) =>
      "Type: ${t['type']}, Amount: ${t['amount']}, Description: ${t['description']}, Date: ${(t['timestamp'] as Timestamp).toDate()}"
      ).join('\n');

      final prompt = '''
      You are a financial assistant. Analyze the following user transaction data and answer the query:
      $transactionData

      User query: $message
      ''';

      final response = await _gemini.textAndImage(text: prompt, images: []);
      setState(() {
        _chatHistory.add({'role': 'assistant', 'content': response?.output ?? "I couldn't process that request."});
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _chatHistory.add({'role': 'assistant', 'content': "An error occurred while processing your request."});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple[900]!, Colors.blue[900]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "AI Financial Wizard",
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.white.withOpacity(0.5),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListView.builder(
                    itemCount: _chatHistory.length,
                    padding: EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final message = _chatHistory[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message['role'] == 'user'
                              ? Colors.blue[700]!.withOpacity(0.7)
                              : Colors.purple[700]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                message['role'] == 'user' ? Icons.person : Icons.auto_awesome,
                                color: message['role'] == 'user' ? Colors.blue[700] : Colors.purple[700],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message['content'] ?? '',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_isLoading)
                Lottie.network(
                  'https://assets3.lottiefiles.com/packages/lf20_szviypry.json',
                  width: 100,
                  height: 100,
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask about your finances...',
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.monetization_on, color: Colors.white70),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_controller.text.isNotEmpty) {
                          _sendMessage(_controller.text);
                          _controller.clear();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.blue],
                          ),
                        ),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
