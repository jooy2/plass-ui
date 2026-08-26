import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PaginationVariants extends StatelessWidget {
  const PaginationVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final variant in <PlassVariant>[
          PlassVariant.ghost,
          PlassVariant.glass,
          PlassVariant.solid,
        ])
          PlPagination(variant: variant, count: 7, page: 3, onPageChanged: (int next) {}),
      ],
    );
  }
}
