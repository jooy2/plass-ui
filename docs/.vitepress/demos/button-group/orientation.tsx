import { PlButton, PlButtonGroup } from 'plass-ui';

export default function ButtonGroupOrientation() {
  return (
    <PlButtonGroup orientation="vertical" variant="glass" color="secondary">
      <PlButton>Rename</PlButton>
      <PlButton>Duplicate</PlButton>
      <PlButton color="danger">Delete</PlButton>
    </PlButtonGroup>
  );
}
