import { PlScrollArea } from 'plass-ui';

const rows = Array.from({ length: 12 }, (_, row) => row + 1);
const columns = Array.from({ length: 8 }, (_, column) => column + 1);

export default function ScrollAreaAxes() {
  return (
    <PlScrollArea
      className="w-full max-w-sm border border-(--plass-border)"
      orientation="both"
      height={200}
      scrollbars="always"
      label="A grid that runs off both edges"
    >
      <div className="w-max">
        {rows.map((row) => (
          <div key={row} className="flex">
            {columns.map((column) => (
              <div key={column} className="w-24 px-3 py-2 text-sm text-(--plass-muted-fg)">
                R{row} C{column}
              </div>
            ))}
          </div>
        ))}
      </div>
    </PlScrollArea>
  );
}
