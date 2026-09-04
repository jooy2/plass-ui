import { PlButton, PlChip, PlFlex } from 'plass-ui';

export default function FlexToolbar() {
  return (
    <PlFlex
      className="w-full max-w-lg"
      spacing={2}
      wrap
      justify="space-between"
      alignItems="center"
    >
      <PlFlex spacing={1.5} wrap alignItems="center">
        <PlChip variant="glass">Design</PlChip>
        <PlChip variant="glass">Engineering</PlChip>
        <PlChip variant="glass">Support</PlChip>
      </PlFlex>

      <PlFlex spacing={2}>
        <PlButton variant="glass" color="secondary">
          Reset
        </PlButton>
        <PlButton>Apply</PlButton>
      </PlFlex>
    </PlFlex>
  );
}
