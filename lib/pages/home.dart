import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static final _weddingDay = DateTime(2026, 8, 22, 19);

  Timer? _timer;
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _passed = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = _weddingDay.difference(DateTime.now());
    if (!mounted) return;
    if (diff.isNegative) {
      setState(() => _passed = true);
      return;
    }
    setState(() {
      _passed = false;
      _days = diff.inDays;
      _hours = diff.inHours % 24;
      _minutes = diff.inMinutes % 60;
      _seconds = diff.inSeconds % 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'home-page', [
      section(classes: 'hero', [
        img(
          classes: 'hero-bg',
          src: 'assets/images/0J1A9346.jpg.jpeg',
          attributes: {
            'srcset':
                'assets/images/0J1A9346.jpg_mobile.jpeg 1000w, assets/images/0J1A9346.jpg.jpeg 2500w',
            'sizes': '100vw',
          },
        ),
        div(classes: 'hero-gradient', []),
        div(classes: 'hero-content', [
          p(classes: 'hero-eyebrow', [text('Save the Date')]),
          h1(classes: 'hero-script', [text('Mohamed')]),
          p(classes: 'hero-amp', [text('&')]),
          h1(classes: 'hero-script', [text('Samar')]),
          p(classes: 'hero-tagline', [
            text('We invite you to celebrate the beginning of our forever.'),
          ]),
          div(classes: 'date-box', [text('22 · 08 · 2026')]),
        ]),
        a(href: '#countdown', classes: 'scroll-cue', [
          span(classes: 'scroll-cue-label', [text('Scroll')]),
          i(classes: 'material-icons', [text('keyboard_arrow_down')]),
        ]),
      ]),

      section(
        id: 'countdown',
        classes: 'countdown-section',
        [
          ..._sectionHead('Counting down', 'Until our wedding day'),
          if (_passed)
            p(classes: 'countdown-done', [text('The celebration has begun!')])
          else
            div(classes: 'countdown-grid', [
              _unit('Days', _days),
              _unit('Hours', _hours),
              _unit('Minutes', _minutes),
              _unit('Seconds', _seconds),
            ]),
        ],
      ),

      section(classes: 'invite-section', [
        ..._sectionHead('With love', 'We are getting married'),
        p(classes: 'invite-text', [
          text(
            'Please join us in celebrating our wedding day. It means the world to us to share this special moment with our closest friends and family.',
          ),
        ]),
      ]),

      section(classes: 'details', [
        ..._sectionHead('The celebration', 'When & where'),
        div(classes: 'info-grid', [
          div(classes: 'info-block', [
            div(classes: 'info-icon-wrap', [
              i(classes: 'material-icons', [text('calendar_today')]),
            ]),
            h3([text('WHEN')]),
            p([
              text('Saturday, August 22, 2026'),
              br(),
              text('At 7:00 PM in the afternoon'),
            ]),
          ]),
          a(
            href: 'https://maps.app.goo.gl/DhTzaHYop9k886Zr5',
            target: Target.blank,
            classes: 'info-block info-block-link',
            [
              div(classes: 'info-icon-wrap', [
                i(classes: 'material-icons', [text('location_on')]),
              ]),
              h3([text('WHERE')]),
              p(classes: 'venue-link', [
                text('Garden plaza el maadi island'),
              ]),
            ],
          ),
        ]),
      ]),

      section(classes: 'program-section', [
        ..._sectionHead('The evening', 'Wedding program'),
        div(classes: 'program-timeline', [
          _programItem('7:00 PM', 'Welcome', 'Arrival and welcome drinks'),
          _programItem('7:30 PM', 'Ceremony', 'We say our vows surrounded by you'),
          _programItem('9:00 PM', 'Dinner', 'Celebration dinner together'),
          _programItem('11:00 PM', 'Dancing', 'Music and dancing under the stars'),
        ]),
      ]),

      section(classes: 'gallery-section', [
        ..._sectionHead('Our moments', 'A glimpse of us'),
        div(classes: 'gallery-grid', [
          div(classes: 'col col-1', [
            img(
              src: 'assets/images/0J1A9329.jpg.jpeg',
              classes: 'photo h-large',
              attributes: {
                'srcset':
                    'assets/images/0J1A9329.jpg_mobile.jpeg 1000w, assets/images/0J1A9329.jpg.jpeg 2500w',
                'sizes': '(max-width: 800px) 100vw, 33vw',
              },
            ),
            img(
              src: 'assets/images/0J1A9208.jpg.jpeg',
              classes: 'photo h-medium',
              attributes: {
                'srcset':
                    'assets/images/0J1A9208.jpg_mobile.jpeg 1000w, assets/images/0J1A9208.jpg.jpeg 2500w',
                'sizes': '(max-width: 800px) 100vw, 33vw',
              },
            ),
          ]),
          div(classes: 'col col-2', [
            img(
              src: 'assets/images/0J1A9330.jpg.jpeg',
              classes: 'photo h-medium',
              attributes: {
                'srcset':
                    'assets/images/0J1A9330.jpg_mobile.jpeg 1000w, assets/images/0J1A9330.jpg.jpeg 2500w',
                'sizes': '(max-width: 800px) 100vw, 33vw',
              },
            ),
            img(
              src: 'assets/images/0J1A9257.jpg.jpeg',
              classes: 'photo h-xlarge',
              attributes: {
                'srcset':
                    'assets/images/0J1A9257.jpg_mobile.jpeg 1000w, assets/images/0J1A9257.jpg.jpeg 2500w',
                'sizes': '(max-width: 800px) 100vw, 33vw',
              },
            ),
          ]),
          div(classes: 'col col-3', [
            img(
              src: 'assets/images/0J1A9334.jpg.jpeg',
              classes: 'photo h-medium',
              attributes: {
                'srcset':
                    'assets/images/0J1A9334.jpg_mobile.jpeg 1000w, assets/images/0J1A9334.jpg.jpeg 2500w',
                'sizes': '(max-width: 800px) 100vw, 33vw',
              },
            ),
            img(
              src: 'assets/images/0J1A9304.jpg.jpeg',
              classes: 'photo h-large',
              attributes: {
                'srcset':
                    'assets/images/0J1A9304.jpg_mobile.jpeg 1000w, assets/images/0J1A9304.jpg.jpeg 2500w',
                'sizes': '(max-width: 800px) 100vw, 33vw',
              },
            ),
          ]),
        ]),
        p(classes: 'closing-text', [
          text("We can't wait to celebrate with you!"),
        ]),
      ]),

      footer([
        h3([text('Mohamed Adel & Samar Tarek')]),
        p([text('22 · 08 · 2026')]),
      ]),
    ]);
  }

  List<Component> _sectionHead(String eyebrow, String title) => [
    p(classes: 'section-eyebrow', [text(eyebrow)]),
    h2(classes: 'title', [text(title)]),
    div(classes: 'divider', []),
  ];

  Component _unit(String label, int value) {
    final padded = value.toString().padLeft(2, '0');
    return div(classes: 'countdown-unit', [
      span(classes: 'countdown-value', [text(padded)]),
      span(classes: 'countdown-unit-label', [text(label)]),
    ]);
  }

  Component _programItem(String time, String title, String desc) {
    return div(classes: 'program-item', [
      div(classes: 'program-time', [text(time)]),
      div(classes: 'program-body', [
        h3([text(title)]),
        p([text(desc)]),
      ]),
    ]);
  }
}
