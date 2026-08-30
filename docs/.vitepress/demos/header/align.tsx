import { PlHeader, type PlassAlign } from 'plass-ui';

export default function HeaderAlign() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['start', 'center', 'end'] as PlassAlign[]).map((align) => (
        <PlHeader
          key={align}
          position="static"
          size="sm"
          align={align}
          brand={<span className="font-semibold">Acme</span>}
          actions={<span className="text-sm text-(--plass-muted-fg)">Account</span>}
        >
          <span className="text-sm">align=&quot;{align}&quot;</span>
        </PlHeader>
      ))}
    </div>
  );
}
