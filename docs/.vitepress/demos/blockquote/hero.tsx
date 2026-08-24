import { PlBlockquote } from 'plass-ui';

export default function BlockquoteHero() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      <PlBlockquote author="Antoine de Saint-Exupéry" source="Terre des hommes">
        Perfection is achieved not when there is nothing more to add, but when there is nothing left
        to take away.
      </PlBlockquote>

      <PlBlockquote variant="glass" color="info" icon={false}>
        A gradient that turns is a piece of tinted glass, and it needs nothing else.
      </PlBlockquote>
    </div>
  );
}
