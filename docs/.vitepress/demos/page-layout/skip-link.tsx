import { PlPageLayout } from 'plass-ui';

export default function PageLayoutSkipLink() {
  return (
    <div className="h-44 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        collapseBelow="none"
        mainId="demo-main"
        skipLabel="Skip to content"
        header={
          <nav className="flex gap-3 border-b [border-color:var(--plass-divider)] p-3 text-sm">
            {['Products', 'Pricing', 'Docs', 'Support'].map((item) => (
              <a key={item} href="#demo-main" className="text-(--plass-muted-fg)">
                {item}
              </a>
            ))}
          </nav>
        }
      >
        <p className="p-4 text-sm">
          Press <kbd>Tab</kbd> from the top of this frame: the first stop is the skip link, which is
          invisible until it holds the focus.
        </p>
      </PlPageLayout>
    </div>
  );
}
