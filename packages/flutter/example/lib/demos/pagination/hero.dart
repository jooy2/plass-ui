import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PaginationHero extends StatefulWidget {
  const PaginationHero({super.key});

  @override
  State<PaginationHero> createState() => _PaginationHeroState();
}

class _PaginationHeroState extends State<PaginationHero> {
  int _page = 4;

  @override
  Widget build(BuildContext context) {
    return PlPagination(
      count: 12,
      page: _page,
      showEdges: true,
      onPageChanged: (int next) => setState(() => _page = next),
    );
  }
}
