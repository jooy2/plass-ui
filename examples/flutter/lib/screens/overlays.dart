import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_ui/plass_ui.dart';

/// One button for each thing that floats over a screen.
class OverlaysScreen extends StatefulWidget {
  /// Creates the screen.
  const OverlaysScreen({super.key});

  @override
  State<OverlaysScreen> createState() => _OverlaysScreenState();
}

class _OverlaysScreenState extends State<OverlaysScreen> {
  final TextEditingController _name = TextEditingController();
  bool _modal = false;
  bool _full = false;
  bool _bottom = false;
  bool _left = false;
  bool _popover = false;
  bool _palette = false;
  bool _overlay = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _button(String label, VoidCallback onPressed) {
    return PlButton(variant: PlassVariant.glass, onPressed: onPressed, child: Text(label));
  }

  @override
  Widget build(BuildContext context) {
    return PushedScreen(
      title: 'Overlays',
      child: PlTooltipProvider(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.paddingOf(context).bottom + 24),
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _button('Modal', () => setState(() => _modal = true)),
                      _button('Full-screen modal', () => setState(() => _full = true)),
                      _button('Bottom drawer', () => setState(() => _bottom = true)),
                      _button('Side drawer', () => setState(() => _left = true)),
                      _button('Overlay', () => setState(() => _overlay = true)),
                      _button('Command palette', () => setState(() => _palette = true)),
                      PlPopover(
                        open: _popover,
                        onOpenChanged: (bool next) => setState(() => _popover = next),
                        title: const Text('Effective rate'),
                        description: const Text('Updated hourly'),
                        trigger: _button('Popover', () => setState(() => _popover = true)),
                        child: const Text('The base rate plus whatever your plan adds to it.'),
                      ),
                      PlMenu(
                        label: 'Actions',
                        items: const <PlMenuEntry>[
                          PlMenuItem(label: 'Cut'),
                          PlMenuItem(label: 'Copy'),
                          PlMenuItem(label: 'Paste'),
                          PlMenuSeparator(),
                          PlMenuItem(label: 'Delete', color: PlassColor.danger),
                        ],
                        trigger: (BuildContext context, VoidCallback open, bool isOpen) {
                          return _button('Menu', open);
                        },
                      ),
                      PlTooltip(
                        content: const Text('Saved two minutes ago'),
                        child: _button('Tooltip', () {}),
                      ),
                      _button('Toast', () {
                        PlToastProvider.of(context).show(
                          const PlToast(
                            color: PlassColor.success,
                            title: Text('Saved'),
                            description: Text('Your changes are live.'),
                          ),
                        );
                      }),
                      _button('Confirm', () {
                        PlConfirmProvider.of(context).confirm(
                          const PlConfirmOptions(
                            title: Text('Delete this project?'),
                            description: Text('It cannot be undone.'),
                            confirmLabel: Text('Delete'),
                            color: PlassColor.danger,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            PlModal(
              open: _modal,
              onOpenChanged: (bool next) => setState(() => _modal = next),
              title: const Text('Rename project'),
              description: const Text('It changes the address as well.'),
              actions: <Widget>[
                PlButton(
                  variant: PlassVariant.ghost,
                  color: PlassColor.secondary,
                  onPressed: () => setState(() => _modal = false),
                  child: const Text('Cancel'),
                ),
                PlButton(
                  onPressed: () => setState(() => _modal = false),
                  child: const Text('Rename'),
                ),
              ],
              child: PlTextField(
                fullWidth: true,
                controller: _name,
                label: const Text('Name'),
                placeholder: 'Aurora',
              ),
            ),
            PlModal(
              open: _full,
              fullScreen: true,
              onOpenChanged: (bool next) => setState(() => _full = next),
              title: const Text('Terms'),
              actions: <Widget>[
                PlButton(
                  onPressed: () => setState(() => _full = false),
                  child: const Text('Close'),
                ),
              ],
              child: const Text('A sheet that takes the whole screen.'),
            ),
            PlDrawer(
              side: PlassSide.bottom,
              open: _bottom,
              onOpenChanged: (bool next) => setState(() => _bottom = next),
              title: const Text('Share'),
              description: const Text('Anyone with the link can read it.'),
              child: PlTextField(
                fullWidth: true,
                controller: _name,
                label: const Text('Note'),
                placeholder: 'Add a note',
              ),
            ),
            PlDrawer(
              side: PlassSide.left,
              open: _left,
              onOpenChanged: (bool next) => setState(() => _left = next),
              title: const Text('Projects'),
              child: const PlList(
                children: <Widget>[
                  PlListItem(child: Text('Aurora')),
                  PlListItem(child: Text('Borealis')),
                  PlListItem(child: Text('Cascade')),
                ],
              ),
            ),
            PlOverlay(
              open: _overlay,
              onOpenChanged: (bool next) => setState(() => _overlay = next),
              child: const Center(child: PlProgressCircular(label: Text('Working'))),
            ),
            PlCommandPalette(
              open: _palette,
              onOpenChanged: (bool next) => setState(() => _palette = next),
              items: const <PlCommandItem>[
                PlCommandItem(value: 'new', label: 'New project'),
                PlCommandItem(value: 'invite', label: 'Invite a colleague'),
                PlCommandItem(value: 'settings', label: 'Open settings'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
