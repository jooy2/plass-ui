import { PlDivider } from 'plass-ui';

export default function DividerHero() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4 text-(--plass-fg)">
      <p className="text-sm">Continue with your work email.</p>
      <PlDivider>OR</PlDivider>
      <p className="text-sm">Use a single sign-on provider.</p>
    </div>
  );
}
