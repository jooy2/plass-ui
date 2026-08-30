import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PageLayoutSpans extends StatelessWidget {
  const PageLayoutSpans({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (final PlPageLayoutSpan span in PlPageLayoutSpan.values) _Shell(span: span),
      ],
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.span});

  final PlPageLayoutSpan span;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return SizedBox(
      width: 260,
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.md]!),
        child: PlPageLayout(
          collapseBelow: null,
          headerSpan: span,
          header: PlToolbar(
            divider: true,
            rounded: false,
            size: PlassSize.xs,
            density: PlassDensity.compact,
            child: Text('headerSpan: ${span.name}', style: const TextStyle(fontSize: 11)),
          ),
          sidebar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: tokens.divider)),
            ),
            child: const SizedBox(
              width: 88,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Navigation', style: TextStyle(fontSize: 11)),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              span == PlPageLayoutSpan.full
                  ? 'The bar takes the corner and the column starts under it.'
                  : 'The column takes the corner and the bar belongs to the view.',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }
}
