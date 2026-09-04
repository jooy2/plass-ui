import { PlAvatar, PlButton, PlFlex, PlTextField } from 'plass-ui';

export default function FlexHero() {
  return (
    <PlFlex
      className="w-full max-w-xl"
      direction={{ xs: 'vertical', md: 'horizontal' }}
      spacing={3}
      alignItems="center"
    >
      <PlAvatar name="Ada Lovelace" />
      <PlTextField className="flex-1" label="Display name" defaultValue="Ada Lovelace" fullWidth />
      <PlButton>Save</PlButton>
    </PlFlex>
  );
}
