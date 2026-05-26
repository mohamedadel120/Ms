import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import 'pages/home.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showPoster = true;
  bool _playingVideo = false;
  bool _showHome = false;

  void _openPoster() {
    if (!_showPoster) return;
    setState(() {
      _showPoster = false;
      _playingVideo = true;
    });
    Timer(const Duration(seconds: 90), () {
      if (mounted && _playingVideo) _onVideoFinished();
    });
  }

  void _onVideoFinished() {
    if (_showHome) return;
    setState(() {
      _playingVideo = false;
      _showHome = true;
    });
  }

  @override
  Component build(BuildContext context) {
    if (_showHome) {
      return div(classes: 'home-mount', [const Home()]);
    }

    if (_showPoster) {
      return div(classes: 'intro-loader', [
        button(
          type: ButtonType.button,
          classes: 'intro-poster-btn',
          events: {'click': (_) => _openPoster()},
          [
            img(
              src: 'assets/intro-poster.jpg',
              classes: 'intro-poster-img',
              attributes: {
                'alt': '',
                'width': '1080',
                'height': '1920',
                'decoding': 'async',
                'fetchpriority': 'high',
              },
            ),
            span(classes: 'intro-cta intro-cta-script', [
              text('Click to open'),
            ]),
          ],
        ),
      ]);
    }

    if (_playingVideo) {
      return div(classes: 'intro-video-wrap', [
        video(
          [],
          src: 'assets/preloader.mp4',
          classes: 'intro-video',
          autoplay: true,
          muted: true,
          attributes: {
            'playsinline': '',
            'preload': 'auto',
            'poster': 'assets/intro-poster.jpg',
            'width': '1080',
            'height': '1920',
          },
          events: {
            'ended': (_) => _onVideoFinished(),
            'error': (_) => _onVideoFinished(),
          },
        ),
      ]);
    }

    return div([]);
  }
}
