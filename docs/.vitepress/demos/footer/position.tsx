import { PlButton, PlFooter } from 'plass-ui';

const rows = Array.from({ length: 12 }, (_, index) => `Field ${index + 1}`);

export default function FooterPosition() {
  return (
    <div className="relative h-64 w-full overflow-y-auto rounded-(--plass-radius-md)">
      <ul className="flex flex-col text-sm">
        {rows.map((row) => (
          <li key={row} className="border-b px-5 py-3 [border-color:var(--plass-divider)]">
            {row}
          </li>
        ))}
      </ul>
      <PlFooter position="sticky" size="sm" density="compact">
        <div className="flex items-center justify-end gap-2">
          <PlButton size="sm" variant="ghost" color="secondary">
            Cancel
          </PlButton>
          <PlButton size="sm">Save</PlButton>
        </div>
      </PlFooter>
    </div>
  );
}
