import { PlWindowPane } from 'plass-ui';

export default function WindowPaneAccent() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-2">
      <PlWindowPane os="windows11" title="In front" accent height={120}>
        <div className="p-4 text-sm text-(--plass-muted-fg)">accent, active</div>
      </PlWindowPane>
      <PlWindowPane os="windows11" title="Behind" active={false} height={120}>
        <div className="p-4 text-sm text-(--plass-muted-fg)">
          its colour drains and its shadow drops a step
        </div>
      </PlWindowPane>
    </div>
  );
}
