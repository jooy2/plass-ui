import { PlWindowPane } from 'plass-ui';

export default function WindowPaneHero() {
  return (
    <PlWindowPane title="Notes" draggable resizable width={420} height={240}>
      <div className="flex h-full flex-col gap-3 p-5">
        <h3 className="text-base font-semibold text-(--plass-fg)">Drag the bar</h3>
        <p className="text-sm text-(--plass-muted-fg)">
          The corner resizes, the three buttons are real buttons with real names, and minimize rolls
          the window up to its bar because a page has nowhere to send it.
        </p>
      </div>
    </PlWindowPane>
  );
}
