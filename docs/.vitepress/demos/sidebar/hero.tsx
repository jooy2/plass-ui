import { PlHeader, PlPageLayout, PlSidebar } from 'plass-ui';

const items = ['Overview', 'Reports', 'Customers', 'Settings'];

export default function SidebarHero() {
  return (
    <div className="h-80 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        scroll="content"
        collapseBelow="none"
        header={<PlHeader size="sm" brand={<span className="font-semibold">Acme</span>} />}
        sidebar={
          <PlSidebar size="sm" label="Main navigation">
            <nav className="flex flex-col gap-1 text-sm">
              {items.map((item, index) => (
                <a
                  key={item}
                  href="#"
                  aria-current={index === 0 ? 'page' : undefined}
                  className="rounded-(--plass-radius-sm) px-2 py-1.5 no-underline aria-[current]:bg-(--plass-primary-soft) aria-[current]:font-medium"
                >
                  {item}
                </a>
              ))}
            </nav>
          </PlSidebar>
        }
      >
        <div className="flex flex-col gap-3 p-5 text-sm">
          <h2 className="text-base font-semibold">Overview</h2>
          <p>
            The column is an <code>&lt;aside&gt;</code>, which is the complementary landmark — the
            region a screen reader offers as related to the page but not the page.
          </p>
        </div>
      </PlPageLayout>
    </div>
  );
}
