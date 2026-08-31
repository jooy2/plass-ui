import { PlCard, PlSegment, PlSegmentedButton, PlTypography, usePlColorScheme } from 'plass-ui';

export default function ColorSchemeDemo() {
  const { scheme, resolved, setScheme } = usePlColorScheme({ storageKey: 'plass-docs-demo' });

  return (
    <PlCard className="w-full">
      <div className="flex flex-col gap-4">
        <PlSegmentedButton
          size="sm"
          aria-label="Colour scheme"
          value={scheme}
          onValueChange={(next) => setScheme(next as typeof scheme)}
        >
          <PlSegment value="light">Light</PlSegment>
          <PlSegment value="dark">Dark</PlSegment>
          <PlSegment value="system">System</PlSegment>
        </PlSegmentedButton>

        <PlTypography level="body">
          Chosen: <strong>{scheme}</strong> · painted: <strong>{resolved}</strong>
        </PlTypography>

        <PlTypography level="caption">
          This one writes on the whole page, so the site around it changes too — and the choice
          survives a reload.
        </PlTypography>
      </div>
    </PlCard>
  );
}
