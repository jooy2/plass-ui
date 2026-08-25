# Example

A complete app, in the two lines that matter: import the library, use a
component. There is no stylesheet to load and no provider to install — a
component follows the platform's brightness until a `PlassTheme` overrides it.

```dart
import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF3F63F2),
      builder: (BuildContext context, Widget? child) {
        final tokens = PlassTheme.of(context);

        return Directionality(
          textDirection: TextDirection.ltr,
          // Glass over a flat page has nothing to be in front of, so the two
          // background tokens exist to give it something.
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[tokens.bgFrom, tokens.bgTo],
              ),
            ),
            child: Center(
              child: PlButton(
                color: PlassColor.primary,
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## The gallery in this directory

`lib/` holds something larger than the snippet above: every demo the
documentation site shows, in one app. It has two modes, and they are the same
code seen from two sides.

```bash
flutter run
```

runs it as a gallery — every demo stacked, with a theme switch. Built for the
web it becomes the renderer behind the Flutter previews on
[plass.cdget.com](https://plass.cdget.com), one demo per frame, which is what
makes those previews a real Flutter build rather than a screenshot.
