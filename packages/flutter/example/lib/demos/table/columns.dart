import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class Member {
  const Member(this.name, this.role, this.seats);

  final String name;
  final String role;
  final String seats;
}

const List<Member> _rows = <Member>[
  Member('Ada Lovelace', 'Owner', '3'),
  Member('Grace Hopper', 'Admin', '1'),
];

class TableColumns extends StatelessWidget {
  const TableColumns({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlTable<Member>(
        rows: _rows,
        columns: <PlTableColumn<Member>>[
          // A share of the leftover width rather than a length: the name column
          // takes three times what the role column does, whatever the sheet
          // turns out to be.
          PlTableColumn<Member>(
            header: const Text('Member'),
            flex: 3,
            cell: (Member row, int index) => Text(row.name),
          ),
          PlTableColumn<Member>(
            header: const Text('Role'),
            cell: (Member row, int index) => Text(row.role),
          ),
          PlTableColumn<Member>(
            header: const Text('Seats'),
            align: PlassAlign.end,
            width: 80,
            cell: (Member row, int index) => Text(row.seats),
          ),
          PlTableColumn<Member>(
            align: PlassAlign.end,
            width: 110,
            cell: (Member row, int index) => PlButton(
              size: PlassSize.xs,
              variant: PlassVariant.ghost,
              color: PlassColor.secondary,
              onPressed: () {},
              child: Text('Edit ${row.name.split(' ').first}'),
            ),
          ),
        ],
      ),
    );
  }
}
