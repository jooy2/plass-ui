import { useState } from 'react';
import { PlPageLayout, PlSidebar } from 'plass-ui';

export default function SidebarResizable() {
  const [width, setWidth] = useState(220);

  return (
    <div className="h-56 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        scroll="content"
        collapseBelow="none"
        sidebar={
          <PlSidebar
            size="sm"
            label="Files"
            resizable
            width={220}
            minWidth={140}
            maxWidth={320}
            onResize={setWidth}
          >
            <span className="text-sm">Drag the inner edge.</span>
          </PlSidebar>
        }
      >
        <p className="p-5 text-sm">
          The column is <strong>{Math.round(width)}px</strong> wide. The handle straddles the edge
          rather than sitting inside it, and the arrow keys move it too.
        </p>
      </PlPageLayout>
    </div>
  );
}
