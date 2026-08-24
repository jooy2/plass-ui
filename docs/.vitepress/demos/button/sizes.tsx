import { PlButton } from 'plass-ui';

export default function ButtonSizes() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton size="xs">Extra small</PlButton>
      <PlButton size="sm">Small</PlButton>
      <PlButton size="md">Medium</PlButton>
      <PlButton size="lg">Large</PlButton>
      <PlButton size="xl">Extra large</PlButton>
    </div>
  );
}
