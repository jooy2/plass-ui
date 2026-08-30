import { PlContainer, PlHeader } from 'plass-ui';

export default function HeaderMeasure() {
  return (
    <div className="w-full">
      <PlHeader
        position="static"
        size="sm"
        maxWidth="sm"
        brand={<span className="font-semibold">Acme</span>}
        actions={<span className="text-sm text-(--plass-muted-fg)">Account</span>}
      />
      <PlContainer size="sm" maxWidth="sm" className="py-4 text-sm">
        The sheet spans the frame; the row inside it stops at the same 40rem the container under it
        does, so the logo and this paragraph sit on one edge.
      </PlContainer>
    </div>
  );
}
