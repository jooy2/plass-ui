import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/app/settings.dart';
import 'package:plass_showcase/screens/components.dart';
import 'package:plass_showcase/screens/media.dart';
import 'package:plass_showcase/screens/overlays.dart';
import 'package:plass_ui/plass_ui.dart';

/// The settings, and the way to the other screens.
class MoreScreen extends StatelessWidget {
  /// Creates the screen.
  const MoreScreen({required this.bottomInset, super.key});

  /// Room held under the content for the bottom bar.
  final double bottomInset;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(ShowcaseRoute<void>(builder: (BuildContext _) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final tokens = PlassTheme.of(context);
    final scale = settings.textScale ?? 1;

    return ScreenScroll(
      title: 'More',
      bottomInset: bottomInset,
      children: <Widget>[
        PlCard(
          child: PlList(
            dividers: true,
            children: <Widget>[
              PlListItem(
                description: const Text('Every demo, one component at a time'),
                onPressed: () => _push(context, const ComponentsScreen()),
                child: const Text('Components'),
              ),
              PlListItem(
                description: const Text('Modal, drawer, menu, toast and the rest'),
                onPressed: () => _push(context, const OverlaysScreen()),
                child: const Text('Overlays'),
              ),
              PlListItem(
                description: const Text('Carousel, gallery and images'),
                onPressed: () => _push(context, const MediaScreen()),
                child: const Text('Media'),
              ),
            ],
          ),
        ),
        PlCard(
          title: const Text('Appearance'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              PlSegmentedButton<String>(
                semanticLabel: 'Theme',
                fullWidth: true,
                value: switch (settings.brightness) {
                  null => 'device',
                  Brightness.light => 'light',
                  Brightness.dark => 'dark',
                },
                onChanged: (String next) {
                  settings.brightness = switch (next) {
                    'light' => Brightness.light,
                    'dark' => Brightness.dark,
                    _ => null,
                  };
                },
                segments: const <PlSegment<String>>[
                  PlSegment<String>(value: 'device', label: Text('Device')),
                  PlSegment<String>(value: 'light', label: Text('Light')),
                  PlSegment<String>(value: 'dark', label: Text('Dark')),
                ],
              ),
              PlSwitch(
                value: tokens.brightness == Brightness.dark,
                onChanged: (bool next) {
                  settings.brightness = next ? Brightness.dark : Brightness.light;
                },
                label: const Text('Dark mode'),
              ),
              PlSwitch(
                value: settings.direction == TextDirection.rtl,
                onChanged: (bool next) {
                  settings.direction = next ? TextDirection.rtl : TextDirection.ltr;
                },
                label: const Text('Right to left'),
                description: const Text('Lays every screen out from the other side.'),
              ),
              PlSwitch(
                value: settings.density == PlassDensity.compact,
                onChanged: (bool next) {
                  settings.density = next ? PlassDensity.compact : PlassDensity.standard;
                },
                label: const Text('Compact'),
              ),
              PlSelect<String>(
                fullWidth: true,
                label: const Text('Language of the built-in labels'),
                value: settings.language,
                onChanged: (String? next) => settings.language = next ?? 'en',
                options: <PlSelectOption<String>>[
                  for (final MapEntry(key: value, value: pack)
                      in ShowcaseSettings.languages.entries)
                    PlSelectOption<String>(value: value, label: Text(pack.$1)),
                ],
              ),
              PlSlider(
                label: const Text('Text size'),
                values: <double>[scale],
                min: 0.8,
                max: 2,
                step: 0.1,
                showValue: true,
                formatValue: (List<double> values) => '${(values.first * 100).round()}%',
                onChanged: (List<double> next) => settings.textScale = next.first,
              ),
            ],
          ),
        ),
        const _Questions(),
      ],
    );
  }
}

class _Questions extends StatefulWidget {
  const _Questions();

  @override
  State<_Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<_Questions> {
  Set<String> _open = <String>{};

  @override
  Widget build(BuildContext context) {
    return PlAccordion<String>(
      value: _open,
      onChanged: (Set<String> next) => setState(() => _open = next),
      items: const <PlAccordionItem<String>>[
        PlAccordionItem<String>(
          value: 'what',
          title: Text('What is this app?'),
          child: Text('A small app built with Plass, to try the library on a real device.'),
        ),
        PlAccordionItem<String>(
          value: 'where',
          title: Text('Where do the pictures come from?'),
          child: Text('They are the sample pictures from the documentation site.'),
        ),
      ],
    );
  }
}
