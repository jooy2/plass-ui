import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/screens/inbox.dart';
import 'package:plass_showcase/screens/more.dart';
import 'package:plass_showcase/screens/orders.dart';
import 'package:plass_showcase/screens/overview.dart';
import 'package:plass_showcase/screens/request.dart';
import 'package:plass_ui/plass_ui.dart';

const Map<String, String> _destinations = <String, String>{
  'overview': 'Overview',
  'inbox': 'Inbox',
  'orders': 'Orders',
  'request': 'Request',
  'more': 'More',
};

/// The five destinations: a bottom bar on a phone and a sidebar on a tablet.
class Shell extends StatefulWidget {
  /// Creates the shell.
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  String _where = 'overview';

  Widget _screen(double bottomInset) {
    return IndexedStack(
      sizing: StackFit.expand,
      index: _destinations.keys.toList().indexOf(_where),
      children: <Widget>[
        OverviewScreen(bottomInset: bottomInset),
        InboxScreen(bottomInset: bottomInset),
        OrdersScreen(bottomInset: bottomInset),
        RequestScreen(bottomInset: bottomInset),
        MoreScreen(bottomInset: bottomInset),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= railBreakpoint;

    if (wide) {
      return Wash(
        child: SafeArea(
          right: false,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 224,
                child: PlSidebar(
                  semanticLabel: 'Main',
                  child: PlList(
                    children: <Widget>[
                      for (final MapEntry(key: value, value: label) in _destinations.entries)
                        PlListItem(
                          selected: _where == value,
                          startIcon: IconTheme(
                            data: IconThemeData(color: tokens.mutedFg, size: 20),
                            child: destinationGlyphs[value]!,
                          ),
                          onPressed: () => setState(() => _where = value),
                          child: Text(label),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(child: _screen(0)),
            ],
          ),
        ),
      );
    }

    return Wash(
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: _screen(72)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PlBottomNavigation<String>(
              label: 'Main',
              value: _where,
              onChanged: (String next) => setState(() => _where = next),
              items: <PlBottomNavigationItem<String>>[
                for (final MapEntry(key: value, value: label) in _destinations.entries)
                  PlBottomNavigationItem<String>(
                    value: value,
                    label: label,
                    icon: destinationGlyphs[value]!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
