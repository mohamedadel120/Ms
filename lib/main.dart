import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(const WeddingApp());
}

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save the Date',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C7355)),
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), // Warm white
        textTheme: GoogleFonts.cormorantGaramondTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 5;
  int _phase = 0; // 0 for countdown, 1 for text
  Timer? _timer;
  late AnimationController _zoomController;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phase == 0) {
        if (_counter > 1) {
          setState(() {
            _counter--;
          });
        } else {
          setState(() {
            _phase = 1;
          });
          _timer?.cancel();
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const InvitationPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  transitionDuration: const Duration(milliseconds: 1500),
                ),
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate blur based on counter. Starts highly blurred, sharpens to 0.
    double targetBlur = _phase == 0 ? (_counter - 1) * 10.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ken Burns Cinematic Zoom & Blur Reveal
          AnimatedBuilder(
            animation: _zoomController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_zoomController.value * 0.15), // Slow zoom in
                child: child,
              );
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 50.0, end: targetBlur),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, blurValue, child) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: blurValue,
                    sigmaY: blurValue,
                  ),
                  child: Image.asset(
                    'assets/images/0J1A9208.jpg.jpeg',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: _phase == 0
                  ? Text(
                      '$_counter',
                      key: ValueKey<int>(_counter),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 120,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  : Column(
                      key: const ValueKey('text'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save the Date',
                          style: GoogleFonts.greatVibes(
                            fontSize: 80,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '22 . 08 . 2026',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            color: Colors.white,
                            letterSpacing: 10,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class InvitationPage extends StatelessWidget {
  const InvitationPage({super.key});

  Widget _buildPhoto(String path, double height) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/texture.png'),
            fit: BoxFit.cover,
            opacity: 0.3, // Subtle vintage paper texture
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Hero Section ---
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/0J1A9346.jpg.jpeg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Dark overlay for text readability
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save the Date',
                          style: GoogleFonts.greatVibes(
                            fontSize: isDesktop ? 80 : 60,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'MOHAMED ADEL\n&\nSAMAR TAREK',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: isDesktop ? 32 : 20,
                            color: Colors.white,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '22 . 08 . 2026',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isDesktop ? 24 : 18,
                              color: Colors.white,
                              letterSpacing: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Details Section ---
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 100 : 30,
                  vertical: 80,
                ),
                child: Column(
                  children: [
                    Text(
                      'We are getting married',
                      style: GoogleFonts.greatVibes(
                        fontSize: isDesktop ? 56 : 42,
                        color: const Color(0xFF5C4033), // Earthy brown
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 60,
                      height: 2,
                      color: const Color(0xFF8C7355),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Please join us in celebrating our wedding day.\nIt means the world to us to share this special moment with our closest friends and family.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: isDesktop ? 24 : 20,
                        color: const Color(0xFF5C4033),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 80),

                    // When & Where
                    Flex(
                      direction: isDesktop ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: isDesktop ? 350 : double.infinity,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF8C7355),
                                size: 40,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'WHEN',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5C4033),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Saturday, August 22, 2026\nAt 7:00 PM in the afternoon',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 20,
                                  color: const Color(0xFF5C4033),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isDesktop)
                          const SizedBox(width: 80)
                        else
                          const SizedBox(height: 60),
                        SizedBox(
                          width: isDesktop ? 350 : double.infinity,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final url = Uri.parse(
                                    'https://maps.app.goo.gl/DhTzaHYop9k886Zr5',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF8C7355),
                                        size: 40,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'WHERE',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF5C4033),
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'Garden plaza el maadi island',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 20,
                                          color: const Color(0xFF5C4033),
                                          decoration: TextDecoration.underline,
                                          decorationColor: const Color(
                                            0xFF8C7355,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Image Gallery Section ---
              Container(
                color: const Color(0xFFFAF5E9), // Light tan background
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 80,
                  horizontal: isDesktop ? 0 : 20,
                ),
                child: Column(
                  children: [
                    Text(
                      'Our Story',
                      style: GoogleFonts.greatVibes(
                        fontSize: isDesktop ? 56 : 42,
                        color: const Color(0xFF5C4033),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 60,
                      height: 2,
                      color: const Color(0xFF8C7355),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: isDesktop ? 1000 : double.infinity,
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildPhoto(
                                        'assets/images/0J1A9329.jpg.jpeg',
                                        450,
                                      ),
                                      _buildPhoto(
                                        'assets/images/0J1A9208.jpg.jpeg',
                                        350,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 80),
                                    child: Column(
                                      children: [
                                        _buildPhoto(
                                          'assets/images/0J1A9330.jpg.jpeg',
                                          400,
                                        ),
                                        _buildPhoto(
                                          'assets/images/0J1A9257.jpg.jpeg',
                                          500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 160),
                                    child: Column(
                                      children: [
                                        _buildPhoto(
                                          'assets/images/0J1A9334.jpg.jpeg',
                                          350,
                                        ),
                                        _buildPhoto(
                                          'assets/images/0J1A9304.jpg.jpeg',
                                          450,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildPhoto(
                                        'assets/images/0J1A9329.jpg.jpeg',
                                        250,
                                      ),
                                      _buildPhoto(
                                        'assets/images/0J1A9334.jpg.jpeg',
                                        320,
                                      ),
                                      _buildPhoto(
                                        'assets/images/0J1A9257.jpg.jpeg',
                                        220,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: Column(
                                      children: [
                                        _buildPhoto(
                                          'assets/images/0J1A9330.jpg.jpeg',
                                          320,
                                        ),
                                        _buildPhoto(
                                          'assets/images/0J1A9208.jpg.jpeg',
                                          220,
                                        ),
                                        _buildPhoto(
                                          'assets/images/0J1A9304.jpg.jpeg',
                                          280,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      'We can\'t wait to celebrate with you!',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: isDesktop ? 28 : 22,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF5C4033),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // --- Footer ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                color: const Color(0xFF5C4033),
                child: Column(
                  children: [
                    Text(
                      'Mohamed Adel & Samar Tarek',
                      style: GoogleFonts.greatVibes(
                        fontSize: 36,
                        color: const Color(0xFFD2B48C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '22 . 08 . 2026',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        color: const Color(0xFFD2B48C),
                        letterSpacing: 3,
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
