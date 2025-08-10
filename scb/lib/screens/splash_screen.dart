import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _tiltController;
  late Animation<Offset> _bounceAnimation;
  late Animation<double> _tiltAnimation; // Tilt animation
  late Animation<double> _fadeAnimation;
  Timer? _timer; // Timer for updating the loading progress
  double _progressValue = 0.0; // Loading bar progress
  final int _durationSeconds = 3; // The delay duration in seconds, changeable

  @override
  void initState() {
    super.initState();

    // Initialize the bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Initialize the tilt animation controller
    _tiltController = AnimationController(
      duration: const Duration(
          milliseconds: 1600), // Longer for smooth back and forth
      vsync: this,
    );

    // Bounce animation with a curved effect
    _bounceAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut, // Elastic curve for bounce
    ));

    // Tilt animation with back-and-forth effect
    _tiltAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: -0.3, end: 0.3),
          weight: 50), // Tilt from bottom to top
      TweenSequenceItem(
          tween: Tween(begin: 0.3, end: -0.1),
          weight: 50), // Tilt back but not as far
    ]).animate(CurvedAnimation(
      parent: _tiltController,
      curve: Curves.easeInOut,
    ));

    // Fade-in effect
    _fadeAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeIn,
    );

    // Start the bounce animation
    _bounceController.forward().whenComplete(() {
      // Start the tilt animation once the bounce completes
      _tiltController.forward();
    });

    // Start the loading timer that updates the progress bar every second
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progressValue +=
            0.1 / _durationSeconds; // Update progress based on duration
        if (_progressValue >= 1) {
          _timer?.cancel();
        }
      });
    });

    // Delay before navigating to the next screen, set by _durationSeconds
    Timer(Duration(seconds: _durationSeconds), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _tiltController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF795548), // Brown background
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _bounceAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Wrench icon with bounce and tilt effect
                      AnimatedBuilder(
                        animation: _tiltController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _tiltAnimation.value, // Apply tilt effect
                            child: const Icon(
                              Icons.build, // Wrench icon
                              size: 100,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // SCB text with bounce effect
                      Text(
                        'SCB',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Slogan text with bounce effect
                      Text(
                        'always for your help',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Loading bar that fills as time progresses
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: LinearProgressIndicator(
              value: _progressValue, // Reflect the progress
              backgroundColor: Colors.white24, // Background of the progress bar
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.white), // Color of the filled part
            ),
          ),
          const SizedBox(height: 20), // Add some spacing below the progress bar
        ],
      ),
    );
  }
}
