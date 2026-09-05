import { PlWindowPane } from 'plass-ui';

export default function WindowPaneTransparency() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-2">
      {[0, 0.45].map((transparency) => (
        <PlWindowPane
          key={transparency}
          os="windows7"
          title={transparency === 0 ? 'Opaque' : 'Translucent'}
          transparency={transparency}
          height={130}
        >
          <div className="p-4 text-sm text-(--plass-muted-fg)">
            The content stays exactly as legible as it was.
          </div>
        </PlWindowPane>
      ))}
    </div>
  );
}
