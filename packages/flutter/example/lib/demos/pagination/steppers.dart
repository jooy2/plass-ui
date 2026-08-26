import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PaginationSteppers extends StatelessWidget {
  const PaginationSteppers({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        PlPagination(count: 9, page: 5, showEdges: true, onPageChanged: (int next) {}),
        PlPagination(count: 9, page: 5, onPageChanged: (int next) {}),
        PlPagination(count: 9, page: 5, showArrows: false, onPageChanged: (int next) {}),
      ],
    );
  }
}
