import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Invoice {
  const Invoice(this.id, this.customer);

  final String id;
  final String customer;
}

class TableEmpty extends StatelessWidget {
  const TableEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlTable<Invoice>(
        rows: const <Invoice>[],
        empty: const Text('No invoices in this period.'),
        columns: <PlTableColumn<Invoice>>[
          PlTableColumn<Invoice>(
            header: const Text('Invoice'),
            cell: (Invoice row, int index) => Text(row.id),
          ),
          PlTableColumn<Invoice>(
            header: const Text('Customer'),
            cell: (Invoice row, int index) => Text(row.customer),
          ),
        ],
      ),
    );
  }
}
