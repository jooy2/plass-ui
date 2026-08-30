import { PlPageLayout, PlSidebar } from 'plass-ui';

export default function SidebarSides() {
  return (
    <div className="h-56 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        scroll="content"
        collapseBelow="none"
        sidebar={
          <PlSidebar size="xs" width={140} label="Navigation">
            <span className="text-xs">Navigation</span>
          </PlSidebar>
        }
        endSidebar={
          <PlSidebar size="xs" width={140} label="On this page">
            <span className="text-xs">On this page</span>
          </PlSidebar>
        }
      >
        <p className="p-5 text-sm">
          Two columns, one on each end. Neither needs a <code>side</code> of its own: the slot it
          was handed to is what decides.
        </p>
      </PlPageLayout>
    </div>
  );
}
