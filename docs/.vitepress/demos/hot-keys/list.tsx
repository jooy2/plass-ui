import { PlHotKeys, PlTable, type PlTableColumn } from 'plass-ui';

interface Row {
  action: string;
  keys: string;
}

const columns: PlTableColumn<Row>[] = [
  { key: 'action', header: 'Action' },
  {
    key: 'keys',
    header: 'Shortcut',
    align: 'end',
    render: (row) => <PlHotKeys size="sm" keys={row.keys} />
  }
];

const rows: Row[] = [
  { action: 'Command palette', keys: 'Mod+K' },
  { action: 'Save', keys: 'Mod+S' },
  { action: 'Find in page', keys: 'Mod+F' },
  { action: 'Close the tab', keys: 'Mod+W' }
];

export default function HotKeysList() {
  return <PlTable size="sm" columns={columns} rows={rows} caption="Keyboard shortcuts" />;
}
