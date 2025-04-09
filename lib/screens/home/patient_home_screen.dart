import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/controllers/home_controller.dart';

class PatientHomeScreen extends StatefulWidget {
  final HomeController controller;
  
  const PatientHomeScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late AnimationController _dotAnimationController;
  
  // Set the maximum number of messages to keep
  final int _maxMessagesToKeep = 8; // This will keep 4 exchanges (4 user + 4 bot messages)
  
  // Update this line with the correct IP address where your Flask API is running
  final String _apiUrl = 'http://10.16.23.227:5001/chat';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    
    // Initialize dot animation controller
    _dotAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    

    if (_messages.isEmpty) {
      // Add initial welcome message with no suggestions
      setState(() {
        _messages.add({
          'text': "Hello! I'm your Brain Tumor Assistant. How can I help you today?",
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      _saveMessages();
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _dotAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedMessages = prefs.getStringList('patient_messages') ?? [];
      
      if (savedMessages.isNotEmpty) {
        setState(() {
          _messages.addAll(
            savedMessages.map((msgStr) => json.decode(msgStr) as Map<String, dynamic>).toList()
          );
        });
      }
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> messagesToSave = _messages
          .map((msg) => json.encode(msg))
          .toList();
      
      await prefs.setStringList('patient_messages', messagesToSave);
    } catch (e) {
      print("Error saving messages: $e");
    }
  }

  // Method to enforce the message limit
  void _enforceMessageLimit() {
    if (_messages.length > _maxMessagesToKeep) {
      setState(() {
        // Keep only the last _maxMessagesToKeep messages
        _messages.removeRange(0, _messages.length - _maxMessagesToKeep);
      });
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    
    setState(() {
      // Add user message
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Show typing indicator
      _isTyping = true;
    });
    
    _scrollToBottom();
    _getChatbotResponse(text);
  }

  Future<void> _getChatbotResponse(String query) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          _messages.add({
            'text': data['answer'],
            'isUser': false,
            'timestamp': DateTime.now().toIso8601String(),
          });
          _isTyping = false;
        });
      } else {
        setState(() {
          _messages.add({
            'text': "I'm sorry, I encountered a problem. Please try again later.",
            'isUser': false,
            'timestamp': DateTime.now().toIso8601String(),
          });
          _isTyping = false;
        });
      }
      
      // Apply message limit after adding the bot's response
      _enforceMessageLimit();
    } catch (e) {
      setState(() {
        _messages.add({
          'text': "Sorry, I couldn't connect to the server. Please check your internet connection and try again.",
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String(),
        });
        _isTyping = false;
      });
      print("Error getting chatbot response: $e");
    }
    
    _saveMessages();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Brain Tumor Bot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 4,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account, color: Colors.white),
            onPressed: () => _switchToDoctor(),
            tooltip: 'Switch to Healthcare Provider',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // Light gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show typing indicator
                  if (_isTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  
                  final message = _messages[index];
                  final bool isUser = message['isUser'] as bool;
                  final String text = message['text'] as String;
                  
                  return Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) 
                            _buildAvatar(isUser: false),
                          
                          const SizedBox(width: 8),
                          
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isUser 
                                    ? Colors.green 
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          if (isUser)
                            _buildAvatar(isUser: true),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            
            // Input area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.green.shade400),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice input coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ask me about brain tumors...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: isUser ? Colors.blue.shade100 : Colors.green.shade100,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person : Icons.health_and_safety,
          size: 20,
          color: isUser ? Colors.blue.shade700 : Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 16),
      child: Row(
        children: [
          _buildAvatar(isUser: false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _dotAnimationController,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (index) {
                    // Create a delayed animation for each dot
                    final delayedValue = (_dotAnimationController.value + (index * 0.2)) % 1.0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 8 + (delayedValue * 4), // Animate size
                      width: 8 + (delayedValue * 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.6 + (delayedValue * 0.4)), // Animate opacity
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchToDoctor() async {
    final shouldSwitch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Switch to Healthcare Provider',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        content: const Text(
          'Are you sure you want to switch to Healthcare Provider mode? '
          'This area is intended for medical professionals.',
          style: TextStyle(fontSize: 15),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('SWITCH', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (shouldSwitch == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'doctor');
        
        // Force app to restart/reload to switch to doctor mode
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // This will trigger the InitialRouter to rebuild
          Navigator.of(context).pushReplacementNamed('/');
        }
      } catch (e) {
        print("Error switching roles: $e");
      }
    }
  }
}