import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Invoice {
  const Invoice(this.id, this.customer, this.status, this.total);

  final String id;
  final String customer;
  final String status;
  final double total;
}

const Map<String, PlassColor> _tone = <String, PlassColor>{
  'Paid': PlassColor.success,
  'Open': PlassColor.primary,
  'Overdue': PlassColor.danger,
};

const List<Invoice> _rows = <Invoice>[
  Invoice('INV-0104', 'Umbrella', 'Open', 2100),
  Invoice('INV-0103', 'Soylent', 'Paid', 640.25),
  Invoice('INV-0102', 'Acme Inc', 'Paid', 1240),
  Invoice('INV-0101', 'Globex', 'Open', 340.5),
  Invoice('INV-0100', 'Initech', 'Overdue', 89),
];

class DataTableHero extends StatelessWidget {
  const DataTableHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      child: PlDataTable<Invoice>(
        caption: const Text('Recent invoices'),
        searchable: true,
        selection: PlDataTableSelection.multiple,
        hoverable: true,
        rows: _rows,
        rowKey: (Invoice row, int _) => row.id,
        columns: <PlDataTableColumn<Invoice>>[
          PlDataTableColumn<Invoice>(
            key: 'id',
            header: const Text('Invoice'),
            width: 110,
            sortable: true,
            value: (Invoice row) => row.id,
            cell: (Invoice row, int _) => Text(row.id),
          ),
          PlDataTableColumn<Invoice>(
            key: 'customer',
            header: const Text('Customer'),
            sortable: true,
            value: (Invoice row) => row.customer,
            cell: (Invoice row, int _) => Text(row.customer),
          ),
          PlDataTableColumn<Invoice>(
            key: 'status',
            header: const Text('Status'),
            sortable: true,
            // The cell is a chip, so the sort and the search are told what it
            // stands for.
            value: (Invoice row) => row.status,
            cell: (Invoice row, int _) =>
                PlChip(size: PlassSize.xs, color: _tone[row.status]!, child: Text(row.status)),
          ),
          PlDataTableColumn<Invoice>(
            key: 'total',
            header: const Text('Total'),
            align: PlassAlign.end,
            sortable: true,
            value: (Invoice row) => row.total,
            cell: (Invoice row, int _) => Text('\$${row.total.toStringAsFixed(2)}'),
          ),
        ],
      ),
    );
  }
}
