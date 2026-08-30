import { PlBox, PlPageLayout, PlToolbar, type PlPageLayoutSpan } from 'plass-ui';

function Shell({ span }: { span: PlPageLayoutSpan }) {
  return (
    <div className="h-52 w-full overflow-hidden rounded-(--plass-radius-md)">
      <PlPageLayout
        height="auto"
        scroll="content"
        collapseBelow="none"
        headerSpan={span}
        header={
          <PlToolbar render={<header />} divider size="xs" density="compact">
            <span className="text-xs font-semibold">headerSpan=&quot;{span}&quot;</span>
          </PlToolbar>
        }
        sidebar={
          <PlBox
            render={<nav />}
            variant="ghost"
            size="xs"
            className="w-28 shrink-0 border-e [border-color:var(--plass-divider)] text-xs"
          >
            Navigation
          </PlBox>
        }
      >
        <p className="p-4 text-xs">
          {span === 'full'
            ? 'The bar takes the corner and the column starts under it. A website.'
            : 'The column takes the corner and the bar belongs to the view. An application.'}
        </p>
      </PlPageLayout>
    </div>
  );
}

export default function PageLayoutSpans() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      <Shell span="full" />
      <Shell span="content" />
    </div>
  );
}
