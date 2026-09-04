import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Person {
  const Person(this.id, this.name, this.role);

  final int id;
  final String name;
  final String role;
}

const List<Person> _rows = <Person>[
  Person(1, 'Ada Lovelace', 'Analyst'),
  Person(2, 'Grace Hopper', 'Compiler'),
  Person(3, 'Karen Spärck Jones', 'Retrieval'),
];

class DataTableLoading extends StatefulWidget {
  const DataTableLoading({super.key});

  @override
  State<DataTableLoading> createState() => _DataTableLoadingState();
}

class _DataTableLoadingState extends State<DataTableLoading> {
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Turns over every few seconds so both states can be seen on one page.
    _timer = Timer.periodic(
      const Duration(milliseconds: 2400),
      (Timer _) => setState(() => _loading = !_loading),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlDataTable<Person>(
        rows: _rows,
        rowKey: (Person row, int _) => row.id,
        loading: _loading,
        columns: <PlDataTableColumn<Person>>[
          PlDataTableColumn<Person>(
            key: 'name',
            header: const Text('Name'),
            cell: (Person row, int _) => Text(row.name),
          ),
          PlDataTableColumn<Person>(
            key: 'role',
            header: const Text('Role'),
            cell: (Person row, int _) => Text(row.role),
          ),
        ],
      ),
    );
  }
}
