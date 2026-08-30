import { PlPageLayout, PlSidebar, type PlassVariant } from 'plass-ui';

export default function SidebarVariants() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-3">
      {(['solid', 'glass', 'ghost'] as PlassVariant[]).map((variant) => (
        <div key={variant} className="h-40 overflow-hidden rounded-(--plass-radius-md)">
          <PlPageLayout
            height="auto"
            scroll="content"
            collapseBelow="none"
            sidebar={
              <PlSidebar size="xs" width={90} variant={variant} label={variant}>
                <span className="text-xs">{variant}</span>
              </PlSidebar>
            }
          >
            <p className="p-3 text-xs">The panel is never dyed.</p>
          </PlPageLayout>
        </div>
      ))}
    </div>
  );
}
