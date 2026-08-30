import { PlHeader, PlPageLayout, PlSidebar, PlSidebarTrigger } from 'plass-ui';

export default function SidebarCollapse() {
  return (
    <div className="h-64 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        scroll="content"
        collapseBelow="lg"
        header={
          <PlHeader
            size="sm"
            brand={
              <>
                <PlSidebarTrigger size="sm" />
                <span className="font-semibold">Acme</span>
              </>
            }
          />
        }
        sidebar={
          <PlSidebar size="sm" label="Main navigation" title="Navigation">
            <nav className="flex flex-col gap-2 text-sm">
              {['Overview', 'Reports', 'Settings'].map((item) => (
                <a key={item} href="#" className="no-underline">
                  {item}
                </a>
              ))}
            </nav>
          </PlSidebar>
        }
      >
        <p className="p-5 text-sm">
          Below <code>lg</code> the column is a drawer and the hamburger is what brings it back.
          Widen the window past 64rem and the button goes away with it.
        </p>
      </PlPageLayout>
    </div>
  );
}
