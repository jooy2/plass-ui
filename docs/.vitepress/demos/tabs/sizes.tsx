import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

export default function TabsSizes() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlTabs key={size} size={size} defaultValue="one">
          <PlTab value="one">{`size="${size}"`}</PlTab>
          <PlTab value="two">Second</PlTab>

          <PlTabPanel value="one">The tabs take the control height ladder.</PlTabPanel>
          <PlTabPanel value="two">So a tab bar lines up with a button beside it.</PlTabPanel>
        </PlTabs>
      ))}
    </div>
  );
}
