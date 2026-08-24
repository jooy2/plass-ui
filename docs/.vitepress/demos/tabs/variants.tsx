import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

export default function TabsVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlTabs key={variant} variant={variant} size="sm" defaultValue="one">
          <PlTab value="one">First</PlTab>
          <PlTab value="two">Second</PlTab>
          <PlTab value="three">Third</PlTab>

          <PlTabPanel value="one">The bar is {variant}.</PlTabPanel>
          <PlTabPanel value="two">Still {variant}.</PlTabPanel>
          <PlTabPanel value="three">And still {variant}.</PlTabPanel>
        </PlTabs>
      ))}
    </div>
  );
}
