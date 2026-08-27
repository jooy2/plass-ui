import { useState } from 'react';
import { PlButton, PlPill } from 'plass-ui';

export default function PillDetails() {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="flex flex-col items-center gap-3">
      <PlPill
        color="info"
        title="Two updates"
        description={expanded ? 'Tap to fold away' : 'Tap to see them'}
        expanded={expanded}
        onClick={() => setExpanded((was) => !was)}
        details={
          <ul className="m-0 list-disc ps-4">
            <li>Billing moved to the new provider.</li>
            <li>Two members are waiting to be approved.</li>
          </ul>
        }
      />

      <PlButton variant="ghost" size="sm" onClick={() => setExpanded((was) => !was)}>
        {expanded ? 'Collapse' : 'Expand'}
      </PlButton>
    </div>
  );
}
