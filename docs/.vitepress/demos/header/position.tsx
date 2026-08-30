import { PlHeader } from 'plass-ui';

const rows = Array.from({ length: 14 }, (_, index) => `Row ${index + 1}`);

export default function HeaderPosition() {
  return (
    <div className="h-64 w-full overflow-y-auto rounded-(--plass-radius-md)">
      <PlHeader
        size="sm"
        brand={<span className="font-semibold">Acme</span>}
        actions={<span className="text-sm text-(--plass-muted-fg)">Account</span>}
      />
      <ul className="flex flex-col text-sm">
        {rows.map((row) => (
          <li key={row} className="border-b px-5 py-3 [border-color:var(--plass-divider)]">
            {row}
          </li>
        ))}
      </ul>
    </div>
  );
}
