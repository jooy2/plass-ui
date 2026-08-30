import { PlContainer, PlFooter } from 'plass-ui';

export default function FooterMeasure() {
  return (
    <div className="w-full">
      <PlContainer size="sm" maxWidth="sm" className="py-4 text-sm">
        The page stops at 40rem, and so does the line under it — the sheet still reaches both edges
        of the frame.
      </PlContainer>
      <PlFooter size="sm" maxWidth="sm">
        <span className="text-xs text-(--plass-muted-fg)">© 2026 Acme</span>
      </PlFooter>
    </div>
  );
}
