import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';

class Reports extends StatefulWidget {
  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final Gemini _gemini = Gemini.instance;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

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
      You are an advanced AI financial assistant with comprehensive knowledge of personal finance, investments, budgeting, economic trends, and global financial markets. Provide detailed, expert-level advice and insights on any finance-related query. Feel free to offer suggestions, explanations, and analysis based on current financial best practices and market conditions. If specific data is needed but not provided, you may make reasonable assumptions to support your response.
    User query: $message
      ''';

      final response = await _gemini.textAndImage(text: prompt, images: []);
      setState(() {
        _chatHistory.add({'role': 'assistant', 'content': response?.output ?? "I couldn't process that request."});
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({'role': 'assistant', 'content': "An error occurred while processing your request."});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFDF6),
      appBar: AppBar(
        backgroundColor: Color(0xFF00897B),
        title: Text(
          "AI Financial Wizard",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatHistory.isEmpty
                ? _buildWelcomeMessage()
                : ListView.builder(
              controller: _scrollController,
              itemCount: _chatHistory.length,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Color(0xFF00897B),
          ),
          SizedBox(height: 20),
          Text(
            "Welcome to your AI Financial Assistant!",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Ask me anything about your finances.",
            style: GoogleFonts.poppins(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16, left: isUser ? 64 : 0, right: isUser ? 0 : 64),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(colors: [Color(0xFF00897B), Color(0xFF005F56)])
              : LinearGradient(colors: [Colors.white, Colors.grey.shade200]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message['content'] ?? '',
          style: GoogleFonts.roboto(
            color: isUser ? Colors.white : Color(0xFF4A4A4A),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask about your finances...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Color(0xFF00897B),
            child: Icon(Icons.send, color: Colors.white, size: 22),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _sendMessage(_controller.text);
                _controller.clear();
              }
            },
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ],
      ),
    );
  }
}
