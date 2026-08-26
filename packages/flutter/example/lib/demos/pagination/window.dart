import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<(int, int)> _shapes = <(int, int)>[(0, 1), (1, 1), (2, 2)];

class PaginationWindow extends StatefulWidget {
  const PaginationWindow({super.key});

  @override
  State<PaginationWindow> createState() => _PaginationWindowState();
}

class _PaginationWindowState extends State<PaginationWindow> {
  int _page = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        for (final (int siblings, int boundary) in _shapes)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: <Widget>[
              PlTypography(
                'siblingCount: $siblings · boundaryCount: $boundary',
                level: PlTypographyLevel.caption,
              ),
              PlPagination(
                count: 20,
                page: _page,
                siblingCount: siblings,
                boundaryCount: boundary,
                onPageChanged: (int next) => setState(() => _page = next),
              ),
            ],
          ),
      ],
    );
  }
}
