import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PaginationSizes extends StatelessWidget {
  const PaginationSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final size in <PlassSize>[PlassSize.xs, PlassSize.sm, PlassSize.md, PlassSize.lg])
          PlPagination(size: size, count: 7, page: 3, onPageChanged: (int next) {}),
      ],
    );
  }
}
