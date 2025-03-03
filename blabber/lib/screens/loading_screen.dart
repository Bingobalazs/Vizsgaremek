import 'package:flutter/material.dart';
// Import your app's home page
import 'package:blabber/main.dart'; // Or FirstRoute or HomePage depending on which one you want to show after loading

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Create a curved animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // Add this to transition to the main app after loading
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Simulate loading or do actual initialization
    await Future.delayed(const Duration(seconds: 2));
    
    // When loading is complete, navigate to your main screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Your existing loading screen UI code here
    const Color primaryRed = Color(0xFFFF204E);
    const Color darkBlue = Color(0xFF00224D);
    const Color white = Colors.white;
    
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your loading animation widgets here
            RotationTransition(
              turns: _animation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const SweepGradient(
                    colors: [primaryRed, darkBlue, white, primaryRed],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: white, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            Text(
              "LOADING",
              style: TextStyle(
                color: white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}