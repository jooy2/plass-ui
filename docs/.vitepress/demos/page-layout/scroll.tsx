import { PlPageLayout, PlToolbar } from 'plass-ui';

const rows = Array.from({ length: 12 }, (_, index) => `Row ${index + 1}`);

export default function PageLayoutScroll() {
  return (
    <div className="h-64 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        scroll="content"
        collapseBelow="none"
        header={
          <PlToolbar render={<header />} divider size="sm">
            <span className="text-sm font-semibold">Pinned by the layout, not by the bar</span>
          </PlToolbar>
        }
        footer={
          <PlToolbar render={<footer />} divider side="bottom" size="sm" density="compact">
            <span className="text-xs text-(--plass-muted-fg)">Always on screen</span>
          </PlToolbar>
        }
      >
        <ul className="flex flex-col divide-y [border-color:var(--plass-divider)] text-sm">
          {rows.map((row) => (
            <li key={row} className="px-5 py-3">
              {row}
            </li>
          ))}
        </ul>
      </PlPageLayout>
    </div>
  );
}
