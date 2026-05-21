import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'dart:async';
import 'pages/home.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _phase =
      0; // 0: closed, 1: opening, 2: letter sliding, 3: dropping, 4: main page

  void _openEnvelope() {
    if (_phase == 0) {
      setState(() {
        _phase = 1; // Flap opens
      });
      Timer(const Duration(milliseconds: 600), () {
        setState(() {
          _phase = 2; // Cards fly out
        });
        Timer(const Duration(milliseconds: 1500), () {
          setState(() {
            _phase = 3; // Cards shuffle
          });
          Timer(const Duration(milliseconds: 2500), () {
            setState(() {
              _phase = 4; // Reveal cards
            });
            Timer(const Duration(milliseconds: 4000), () {
              setState(() {
                _phase = 5; // Main page
              });
            });
          });
        });
      });
    }
  }

  @override
  Component build(BuildContext context) {
    if (_phase < 5) {
      return div(
        classes: 'splash-screen phase-$_phase',
        events: {'click': (e) => _openEnvelope()},
        [
          // Background Ken Burns image
          div(classes: 'bg-blur', []),

          // Dark Overlay
          div(classes: 'overlay', []),

          // Tap to open text
          if (_phase == 0)
            div(classes: 'tap-to-open', [
              i(classes: 'material-icons', [text('touch_app')]),
              text(' Tap to open'),
            ]),

          // Title Reveal in Phase 4
          div(classes: 'bride-groom-title phase-$_phase', [
            text('Mohamed & Samar'),
          ]),

          // Envelope Container
          div(classes: 'envelope-container', [
            // Envelope Back Flap (moved to back of DOM so cards are in front)
            div(classes: 'envelope-back', []),

            // Left Card (Day & Month)
            div(classes: 'card card-left phase-$_phase', [
              div(classes: 'card-inner', [
                div(classes: 'card-front', [
                  h2([text('22')]),
                  p([text('August')]),
                ]),
                div(classes: 'card-back', [text('M&S')]),
              ]),
            ]),

            // Middle Card (Image)
            div(classes: 'card card-middle phase-$_phase', [
              div(classes: 'card-inner', [
                div(classes: 'card-front', [
                  img(
                    src: 'assets/images/0J1A9346.jpg.jpeg',
                    classes: 'card-image',
                    attributes: {
                      'srcset':
                          'assets/images/0J1A9346.jpg_mobile.jpeg 1000w, assets/images/0J1A9346.jpg.jpeg 2500w',
                      'sizes': '300px',
                    },
                  ),
                ]),
                div(classes: 'card-back', [text('M&S')]),
              ]),
            ]),

            // Right Card (Year)
            div(classes: 'card card-right phase-$_phase', [
              div(classes: 'card-inner', [
                div(classes: 'card-front', [
                  h2([text('2026')]),
                ]),
                div(classes: 'card-back', [text('M&S')]),
              ]),
            ]),

            // Hearts burst (visible during phase 2)
            if (_phase >= 2)
              div(classes: 'hearts-burst', [
                i(classes: 'material-icons heart h1', [text('favorite')]),
                i(classes: 'material-icons heart h2', [text('favorite')]),
                i(classes: 'material-icons heart h3', [text('favorite')]),
              ]),

            // Envelope Front Flaps (Bottom/Sides)
            div(classes: 'envelope-front', []),

            // Envelope Top Flap (Closed -> Open)
            div(classes: 'envelope-top', []),

            // Wax seal
            div(classes: 'wax-seal', [text('M&S')]),
          ]),
        ],
      );
    } else {
      return const Home();
    }
  }
}
