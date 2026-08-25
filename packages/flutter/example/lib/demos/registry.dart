import 'package:flutter/widgets.dart';

import 'package:plass_ui_example/demos/button/colors.dart';
import 'package:plass_ui_example/demos/button/density.dart';
import 'package:plass_ui_example/demos/button/elevation.dart';
import 'package:plass_ui_example/demos/button/full_width.dart';
import 'package:plass_ui_example/demos/button/hero.dart';
import 'package:plass_ui_example/demos/button/icons.dart';
import 'package:plass_ui_example/demos/button/sizes.dart';
import 'package:plass_ui_example/demos/button/states.dart';
import 'package:plass_ui_example/demos/button/variants.dart';

/// Every demo, under the key the documentation asks for it by.
///
/// The keys are the same strings the React demos live at — `<Demo
/// src="button/variants" />` in the Markdown resolves to
/// `.vitepress/demos/button/variants.tsx` on one side and to this map on the
/// other — so a preview that exists in both packages needs no second list
/// anywhere to say so.
///
/// A React demo with no entry here is one the Flutter package has not reached
/// yet, and the gallery says exactly that rather than rendering an empty box.
const Map<String, WidgetBuilder> demos = <String, WidgetBuilder>{
  'button/hero': _hero,
  'button/variants': _variants,
  'button/colors': _colors,
  'button/sizes': _sizes,
  'button/density': _density,
  'button/icons': _icons,
  'button/states': _states,
  'button/elevation': _elevation,
  'button/full-width': _fullWidth,
};

Widget _hero(BuildContext context) => const ButtonHero();
Widget _variants(BuildContext context) => const ButtonVariants();
Widget _colors(BuildContext context) => const ButtonColors();
Widget _sizes(BuildContext context) => const ButtonSizes();
Widget _density(BuildContext context) => const ButtonDensity();
Widget _icons(BuildContext context) => const ButtonIcons();
Widget _states(BuildContext context) => const ButtonStates();
Widget _elevation(BuildContext context) => const ButtonElevation();
Widget _fullWidth(BuildContext context) => const ButtonFullWidth();
