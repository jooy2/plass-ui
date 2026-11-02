import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/data/sample.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

/// A table of orders, with a filter drawer and actions on each order.
class OrdersScreen extends StatefulWidget {
  /// Creates the screen.
  const OrdersScreen({required this.bottomInset, super.key});

  /// Room held under the content for the bottom bar.
  final double bottomInset;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final Set<String> _statuses = <String>{'Paid', 'Open', 'Overdue'};
  final List<String> _removed = <String>[];
  bool _filters = false;

  Future<void> _remove(Order order) async {
    final ok = await PlConfirmProvider.of(context).confirm(
      PlConfirmOptions(
        title: Text('Delete ${order.id}?'),
        description: const Text('It cannot be brought back.'),
        confirmLabel: const Text('Delete'),
        color: PlassColor.danger,
      ),
    );

    if (!ok || !mounted) {
      return;
    }

    setState(() => _removed.add(order.id));
    PlToastProvider.of(context).show(
      PlToast(
        color: PlassColor.danger,
        title: Text('Deleted ${order.id}'),
        actionLabel: const Text('Undo'),
        onAction: () => setState(() => _removed.remove(order.id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = orders
        .where((Order one) => _statuses.contains(one.status) && !_removed.contains(one.id))
        .toList();

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: ScreenScroll(
            title: 'Orders',
            subtitle: '${rows.length} shown',
            bottomInset: widget.bottomInset,
            action: PlButton(
              variant: PlassVariant.glass,
              color: PlassColor.secondary,
              size: PlassSize.sm,
              onPressed: () => setState(() => _filters = true),
              child: const Text('Filters'),
            ),
            children: <Widget>[
              PlDataTable<Order>(
                caption: const Text('Orders'),
                searchable: true,
                paging: PlDataTablePaging.pages,
                pageSize: 8,
                rows: rows,
                rowKey: (Order row, int _) => row.id,
                columns: <PlDataTableColumn<Order>>[
                  PlDataTableColumn<Order>(
                    key: 'id',
                    header: const Text('Order'),
                    width: 104,
                    sortable: true,
                    value: (Order row) => row.id,
                    cell: (Order row, int _) => Text(row.id),
                  ),
                  PlDataTableColumn<Order>(
                    key: 'customer',
                    header: const Text('Customer'),
                    width: 120,
                    sortable: true,
                    value: (Order row) => row.customer,
                    cell: (Order row, int _) => Text(row.customer),
                  ),
                  PlDataTableColumn<Order>(
                    key: 'status',
                    header: const Text('Status'),
                    width: 104,
                    value: (Order row) => row.status,
                    cell: (Order row, int _) => PlChip(
                      size: PlassSize.xs,
                      color: statusColors[row.status]!,
                      child: Text(row.status),
                    ),
                  ),
                  PlDataTableColumn<Order>(
                    key: 'total',
                    header: const Text('Total'),
                    width: 104,
                    align: PlassAlign.end,
                    sortable: true,
                    value: (Order row) => row.total,
                    cell: (Order row, int _) => Text('£${row.total.toStringAsFixed(2)}'),
                  ),
                  PlDataTableColumn<Order>(
                    key: 'actions',
                    header: const SizedBox.shrink(),
                    width: 56,
                    value: (Order row) => row.id,
                    cell: (Order row, int _) => PlMenu(
                      label: 'Actions for ${row.id}',
                      items: <PlMenuEntry>[
                        const PlMenuItem(label: 'Open'),
                        PlMenuItem(
                          label: 'Delete',
                          color: PlassColor.danger,
                          onPressed: () => _remove(row),
                        ),
                      ],
                      trigger: (BuildContext context, VoidCallback open, bool isOpen) {
                        return PlIconButton(
                          label: 'Actions for ${row.id}',
                          size: PlassSize.xs,
                          variant: PlassVariant.ghost,
                          color: PlassColor.secondary,
                          icon: const MoreGlyph(),
                          onPressed: open,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PlDrawer(
          side: PlassSide.right,
          open: _filters,
          onOpenChanged: (bool next) => setState(() => _filters = next),
          title: const Text('Filters'),
          description: const Text('Show orders that are:'),
          actions: <Widget>[
            PlButton(onPressed: () => setState(() => _filters = false), child: const Text('Done')),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              for (final String status in statusColors.keys)
                PlSwitch(
                  value: _statuses.contains(status),
                  onChanged: (bool next) => setState(() {
                    next ? _statuses.add(status) : _statuses.remove(status);
                  }),
                  label: Text(status),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
