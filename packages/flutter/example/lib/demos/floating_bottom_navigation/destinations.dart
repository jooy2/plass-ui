import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

/// The four destinations every floating-bar demo uses. See the
/// bottom-navigation folder's own list for why this is a file and not a demo.
const List<PlFloatingBottomNavigationItem<String>> destinations =
    <PlFloatingBottomNavigationItem<String>>[
      PlFloatingBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeGlyph()),
      PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchGlyph()),
      PlFloatingBottomNavigationItem<String>(value: 'saved', label: 'Saved', icon: BookmarkGlyph()),
      PlFloatingBottomNavigationItem<String>(
        value: 'account',
        label: 'Account',
        icon: AccountGlyph(),
      ),
    ];
