import { PlBox, PlButton, PlFooter, PlHeader, PlPageLayout } from 'plass-ui';

export default function PageLayoutHero() {
  return (
    <div className="h-80 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        scroll="content"
        collapseBelow="none"
        header={
          <PlHeader
            size="sm"
            brand={<span className="font-semibold">Acme</span>}
            actions={<PlButton size="sm">Sign in</PlButton>}
          />
        }
        sidebar={
          <PlBox
            render={<nav />}
            variant="ghost"
            size="sm"
            className="w-44 shrink-0 border-e [border-color:var(--plass-divider)]"
          >
            <ul className="flex flex-col gap-2 text-sm">
              {['Overview', 'Reports', 'Settings'].map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </PlBox>
        }
        footer={
          <PlFooter size="sm" density="compact">
            <span className="text-xs text-(--plass-muted-fg)">© 2026 Acme</span>
          </PlFooter>
        }
      >
        <div className="flex flex-col gap-3 p-5 text-sm">
          <h2 className="text-base font-semibold">Overview</h2>
          <p>Everything between the bars is the main landmark, and it is the part that scrolls.</p>
          <p className="text-(--plass-muted-fg)">
            The layout draws no surface of its own — it decides where the four regions go and gives
            the page its landmarks.
          </p>
        </div>
      </PlPageLayout>
    </div>
  );
}
