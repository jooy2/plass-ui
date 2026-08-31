import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProviderDefaults extends StatefulWidget {
  const ProviderDefaults({super.key});

  @override
  State<ProviderDefaults> createState() => _ProviderDefaultsState();
}

class _ProviderDefaultsState extends State<ProviderDefaults> {
  PlassSize _size = PlassSize.md;
  PlassDensity _density = PlassDensity.standard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Wrap(
            spacing: 12,
            children: <Widget>[
              PlSegmentedButton<PlassSize>(
                size: PlassSize.sm,
                value: _size,
                onChanged: (PlassSize next) => setState(() => _size = next),
                segments: const <PlSegment<PlassSize>>[
                  PlSegment<PlassSize>(value: PlassSize.sm, label: Text('sm')),
                  PlSegment<PlassSize>(value: PlassSize.md, label: Text('md')),
                  PlSegment<PlassSize>(value: PlassSize.lg, label: Text('lg')),
                ],
              ),
              PlSegmentedButton<PlassDensity>(
                size: PlassSize.sm,
                value: _density,
                onChanged: (PlassDensity next) => setState(() => _density = next),
                segments: const <PlSegment<PlassDensity>>[
                  PlSegment<PlassDensity>(value: PlassDensity.standard, label: Text('standard')),
                  PlSegment<PlassDensity>(value: PlassDensity.compact, label: Text('compact')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Nothing below this line says `size` or `density`.
          PlassTheme.merge(
            defaults: PlassDefaults(size: _size, density: _density),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 200,
                  child: PlTextField(label: const Text('Email'), placeholder: 'ada@…'),
                ),
                PlButton(onPressed: () {}, child: const Text('Save')),
                PlButton(
                  variant: PlassVariant.glass,
                  color: PlassColor.secondary,
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                PlCheckbox(value: true, onChanged: (bool? _) {}, label: const Text('Remember me')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
