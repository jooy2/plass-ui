import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Invoice {
  const Invoice(this.id, this.customer, this.status, this.total);

  final String id;
  final String customer;
  final String status;
  final String total;
}

const List<Invoice> _rows = <Invoice>[
  Invoice('INV-0102', 'Acme Inc', 'Paid', r'$1240.00'),
  Invoice('INV-0101', 'Globex', 'Open', r'$340.50'),
  Invoice('INV-0100', 'Initech', 'Overdue', r'$89.00'),
];

class TableHero extends StatelessWidget {
  const TableHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlTable<Invoice>(
        caption: const Text('Recent invoices'),
        hoverable: true,
        rows: _rows,
        columns: <PlTableColumn<Invoice>>[
          PlTableColumn<Invoice>(
            header: const Text('Invoice'),
            width: 110,
            cell: (Invoice row, int index) => Text(row.id),
          ),
          PlTableColumn<Invoice>(
            header: const Text('Customer'),
            cell: (Invoice row, int index) => Text(row.customer),
          ),
          PlTableColumn<Invoice>(
            header: const Text('Status'),
            cell: (Invoice row, int index) => Text(row.status),
          ),
          PlTableColumn<Invoice>(
            header: const Text('Total'),
            align: PlassAlign.end,
            cell: (Invoice row, int index) => Text(row.total),
          ),
        ],
      ),
    );
  }
}
