import { PlBox, PlTypography } from 'plass-ui';

export default function BoxHero() {
  return (
    <PlBox className="w-full max-w-sm">
      <PlTypography level="h6" gutter>
        Storage
      </PlTypography>
      <PlTypography level="body">
        A sheet of glass with content on it. It groups things, and that is all it does.
      </PlTypography>
    </PlBox>
  );
}
