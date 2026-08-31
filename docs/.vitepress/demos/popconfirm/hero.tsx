import { useState } from 'react';
import { PlButton, PlList, PlListItem, PlPopconfirm, PlTypography } from 'plass-ui';

const start = ['Q3 report', 'Onboarding notes', 'Pricing draft'];

export default function PopconfirmHero() {
  const [rows, setRows] = useState(start);

  return (
    <div className="w-full max-w-sm">
      <PlList>
        {rows.map((row) => (
          <PlListItem
            key={row}
            title={row}
            action={
              <PlPopconfirm
                title="Delete this file?"
                description="It cannot be undone."
                confirmLabel="Delete"
                trigger={
                  <PlButton size="sm" variant="ghost" color="danger">
                    Delete
                  </PlButton>
                }
                onConfirm={() => setRows((current) => current.filter((entry) => entry !== row))}
              />
            }
          />
        ))}
      </PlList>

      {rows.length === 0 ? (
        <PlButton size="sm" variant="glass" className="mt-3" onClick={() => setRows(start)}>
          Put them back
        </PlButton>
      ) : (
        <PlTypography level="caption" className="mt-3 block text-(--plass-muted-fg)">
          The question appears against the row it is about.
        </PlTypography>
      )}
    </div>
  );
}
