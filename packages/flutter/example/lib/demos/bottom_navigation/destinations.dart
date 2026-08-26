import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

/// The four destinations every bottom-navigation demo uses.
///
/// A file under `demos/` that is not itself a demo, the way `file_picker/fake`
/// is: four demos of the same bar should be four demos of *the same bar*, and
/// the only way to guarantee that is one list.
const List<PlBottomNavigationItem<String>> destinations = <PlBottomNavigationItem<String>>[
  PlBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeGlyph()),
  PlBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchGlyph()),
  PlBottomNavigationItem<String>(value: 'saved', label: 'Saved', icon: BookmarkGlyph()),
  PlBottomNavigationItem<String>(value: 'account', label: 'Account', icon: AccountGlyph()),
];
