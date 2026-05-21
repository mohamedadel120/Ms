import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math';

String getResponsiveImagePath(String path, BuildContext context) {
  if (path.endsWith('.png')) return path; // Skip textures
  bool isDesktop = MediaQuery.of(context).size.width > 800;
  if (isDesktop) return path;

  final ext = path.split('.').last;
  final basePath = path.substring(0, path.length - ext.length - 1);
  return '${basePath}_mobile.$ext';
}

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
    with TickerProviderStateMixin {
  int _phase =
      0; // 0: floating, 1: flap opening, 2: letter sliding, 3: dropping, 4: navigating
  late AnimationController _zoomController;
  late AnimationController _floatController;
  late AnimationController _flapController;
  late AnimationController _letterController;
  late AnimationController _dropController;

  double _frozenFloatValue = 0;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _flapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _letterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flapController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _phase = 2;
        });
        _letterController.forward();
      }
    });

    _letterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _phase = 3;
        });
        // Small delay so user can read the letter before it scales and transitions
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _dropController.forward();
          }
        });
      }
    });

    _dropController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _phase = 4;
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const InvitationPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 1200),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _floatController.dispose();
    _flapController.dispose();
    _letterController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _openEnvelope() {
    if (_phase == 0) {
      _frozenFloatValue = _floatController.value;
      _floatController.stop();
      setState(() {
        _phase = 1;
      });
      _flapController.forward();
    }
  }

  Widget _buildHeart(double progress, double xOffset, double speed, double scaleOffset) {
    if (progress <= 0) return const SizedBox();
    double y = 140 - (progress * 250 * speed); // Moves up from inside envelope
    double opacity = progress < 0.8 ? progress * 2 : (1.0 - progress) * 5; 
    opacity = opacity.clamp(0.0, 1.0);
    double scale = scaleOffset + (progress * 0.5);
    
    return Positioned(
      bottom: y,
      left: 160 + xOffset - 12, // center minus half icon size
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: const Icon(Icons.favorite, color: Color(0xFF8C1C13), size: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double targetBlur = _phase == 0 ? 40.0 : 0.0;

    final floatCurve = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutSine,
    );
    final flapCurve = CurvedAnimation(
      parent: _flapController,
      curve: Curves.easeInOutBack,
    ); // bouncy flap!
    final letterCurve = CurvedAnimation(
      parent: _letterController,
      curve: Curves.easeOutBack,
    );
    final dropCurve = CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeInBack,
    ); // pulls back then drops!

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ken Burns Background
          AnimatedBuilder(
            animation: _zoomController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_zoomController.value * 0.15),
                child: child,
              );
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 40.0, end: targetBlur),
              duration: Duration(milliseconds: _phase == 0 ? 0 : 3000),
              curve: Curves.easeOut,
              builder: (context, blurValue, child) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: blurValue,
                    sigmaY: blurValue,
                  ),
                  child: Image.asset(
                    getResponsiveImagePath(
                      'assets/images/0J1A9208.jpg.jpeg',
                      context,
                    ),
                    fit: BoxFit.cover,
                    cacheWidth: isDesktop ? 1200 : null,
                    filterQuality: FilterQuality.high,
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ), // Darker overlay for contrast

          Center(
            child: _phase < 4
                ? GestureDetector(
                    key: const ValueKey('envelope'),
                    onTap: _openEnvelope,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _floatController,
                        _flapController,
                        _letterController,
                        _dropController,
                      ]),
                      builder: (context, child) {
                        // No floating or tilting when closed - sits normally
                        double floatOffset = 0.0;
                        double envelopeDrop = _phase >= 3
                            ? dropCurve.value * 1000
                            : 0;
                        double totalEnvelopeY = floatOffset + envelopeDrop;
                        double letterY = floatOffset;

                        // No 3D tilt when closed
                        double tiltY = 0.0;
                        double tiltX = 0.0;

                        return SizedBox(
                          width: 320,
                          height: 220,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(tiltY)
                              ..rotateX(tiltX),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              // 1. Envelope Back
                              Positioned.fill(
                                child: Transform.translate(
                                  offset: Offset(0, totalEnvelopeY),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC4A47C),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.6),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // 2. Opened Top Flap (Rotates 90 to 180)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: Offset(0, totalEnvelopeY),
                                  child: Transform(
                                    alignment: Alignment.topCenter,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateX(flapCurve.value * -pi),
                                    child: flapCurve.value > 0.5
                                        ? ClipPath(
                                            clipper: TopFlapClipper(),
                                            child: Container(
                                              height: 140,
                                              color: const Color(0xFFB59368),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                              ),

                              // 3. Sliding Letter
                              Positioned(
                                bottom:
                                    10 +
                                    (letterCurve.value *
                                        280), // Slide up higher!
                                left: 15,
                                right: 15,
                                child: Transform.translate(
                                  offset: Offset(0, letterY),
                                  child: Transform.scale(
                                    scale:
                                        1.0 +
                                        (dropCurve.value *
                                            0.4), // Scale up letter
                                    child: Opacity(
                                      opacity: (1.0 - (dropCurve.value * 0.5))
                                          .clamp(0.0, 1.0), // Fade slightly
                                      child: Container(
                                        height: 190,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDFBF7),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                          image: const DecorationImage(
                                            image: AssetImage(
                                              'assets/images/texture.png',
                                            ),
                                            fit: BoxFit.cover,
                                            opacity: 0.1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Save the Date',
                                                style: GoogleFonts.greatVibes(
                                                  fontSize: 38,
                                                  color: const Color(
                                                    0xFF5C4033,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Text(
                                                '22 . 08 . 2026',
                                                style:
                                                    GoogleFonts.playfairDisplay(
                                                      fontSize: 16,
                                                      letterSpacing: 4,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                        0xFF5C4033,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 3.5 Floating Hearts Burst
                              if (_phase >= 2 && _phase < 4) ...[
                                _buildHeart(letterCurve.value, -60, 0.9, 0.8),
                                _buildHeart(letterCurve.value, 50, 1.2, 1.0),
                                _buildHeart(letterCurve.value, 0, 1.5, 0.6),
                              ],

                              // 4. Front Flaps
                              Positioned.fill(
                                child: Transform.translate(
                                  offset: Offset(0, totalEnvelopeY),
                                  child: ClipPath(
                                    clipper: FrontFlapsClipper(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCBAA80),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: CustomPaint(
                                        painter: EnvelopeLinesPainter(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 5. Closed Top Flap (Rotates 0 to 90) + Wax Seal
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: Offset(0, totalEnvelopeY),
                                  child: Transform(
                                    alignment: Alignment.topCenter,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateX(flapCurve.value * -pi),
                                    child: flapCurve.value <= 0.5
                                        ? Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.topCenter,
                                            children: [
                                              ClipPath(
                                                clipper: TopFlapClipper(),
                                                child: Container(
                                                  height: 140,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFDAB78A),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              // Wax Seal
                                              Positioned(
                                                top: 105, // Tip of flap
                                                child: Container(
                                                  width: 55,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color(
                                                      0xFF8C1C13,
                                                    ), // Deep red wax
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFF7A150F,
                                                      ),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'M&S',
                                                      style:
                                                          GoogleFonts.greatVibes(
                                                            color: const Color(
                                                              0xFFE5D3B3,
                                                            ),
                                                            fontSize: 22,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                              ),

                              // 6. Tap to Open Indicator
                              if (_phase == 0)
                                Positioned(
                                  bottom: -50,
                                  left: 0,
                                  right: 0,
                                  child: Opacity(
                                    opacity: 0.4 + (floatCurve.value * 0.6), // Pulses with the float
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.touch_app, color: Colors.white, size: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Tap to open',
                                            style: GoogleFonts.greatVibes(
                                              color: Colors.white,
                                              fontSize: 32,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

// --- Custom Clippers & Painters for the Envelope ---

class FrontFlapsClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height / 2 + 15); // Dip in the center
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TopFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height); // Pointing down
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class EnvelopeLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Line from bottom corners to center to simulate folded flaps
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2 + 15);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, paint);

    // Top V edge
    Path vEdge = Path();
    vEdge.moveTo(0, 0);
    vEdge.lineTo(size.width / 2, size.height / 2 + 15);
    vEdge.lineTo(size.width, 0);
    canvas.drawPath(vEdge, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class InvitationPage extends StatelessWidget {
  const InvitationPage({super.key});

  Widget _buildPhoto(String path, double height) {
    return Builder(
      builder: (context) {
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
            image: DecorationImage(
              image: ResizeImage(
                AssetImage(getResponsiveImagePath(path, context)),
                width: 800, // Forces high-quality downsampling at decode time
              ),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        );
      },
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
            filterQuality: FilterQuality.high,
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
                      getResponsiveImagePath(
                        'assets/images/0J1A9346.jpg.jpeg',
                        context,
                      ),
                      fit: BoxFit.cover,
                      cacheWidth: isDesktop ? 1200 : null,
                      filterQuality: FilterQuality.high,
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
