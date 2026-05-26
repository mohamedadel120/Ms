import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static final _weddingAt = DateTime(2026, 8, 22, 19);

  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _passed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final diff = _weddingAt.difference(DateTime.now());
    if (diff.isNegative) {
      if (!_passed) {
        setState(() => _passed = true);
      }
      return;
    }
    final next = (
      days: diff.inDays,
      hours: diff.inHours % 24,
      minutes: diff.inMinutes % 60,
      seconds: diff.inSeconds % 60,
    );
    if (next.days != _days ||
        next.hours != _hours ||
        next.minutes != _minutes ||
        next.seconds != _seconds ||
        _passed) {
      setState(() {
        _passed = false;
        _days = next.days;
        _hours = next.hours;
        _minutes = next.minutes;
        _seconds = next.seconds;
      });
    }
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
        div(classes: 'hero-content', [
          p(classes: 'hero-script', [text('Save the Date')]),
          h1(classes: 'hero-names', [
            text('MOHAMED ADEL'),
            br(),
            span(classes: 'hero-amp', [text('&')]),
            br(),
            text('SAMAR TAREK'),
          ]),
          div(classes: 'date-box', [text('22 . 08 . 2026')]),
        ]),
      ]),

      section(classes: 'countdown-section', [
        p(classes: 'countdown-label', [text('Counting down to our wedding')]),
        if (_passed)
          p(classes: 'countdown-done', [text('The celebration has begun!')])
        else
          div(classes: 'countdown-grid', [
            _unit(_days, 'Days'),
            _unit(_hours, 'Hours'),
            _unit(_minutes, 'Minutes'),
            _unit(_seconds, 'Seconds'),
          ]),
      ]),

      div(classes: 'page-body', [
        div(classes: 'texture-overlay', []),

        section(classes: 'details', [
          h2(classes: 'title', [text('We are getting married')]),
          div(classes: 'divider', []),
          p(classes: 'subtitle', [
            text('Please join us in celebrating our wedding day.'),
            br(),
            text(
              'It means the world to us to share this special moment with our closest friends and family.',
            ),
          ]),
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

        section(classes: 'gallery-section', [
          h2(classes: 'title', [text('Our Story')]),
          div(classes: 'divider', []),
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
          p([text('22 . 08 . 2026')]),
        ]),
      ]),
    ]);
  }

  Component _unit(int value, String label) {
    final padded = value.toString().padLeft(2, '0');
    return div(classes: 'countdown-unit', [
      span(classes: 'countdown-value', [text(padded)]),
      span(classes: 'countdown-unit-label', [text(label)]),
    ]);
  }
}
