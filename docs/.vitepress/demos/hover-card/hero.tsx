import { PlHoverCard, PlTextLink } from 'plass-ui';

export default function HoverCardHero() {
  return (
    <p className="max-w-md text-center leading-7">
      The notes were written by{' '}
      <PlHoverCard
        title="Ada Lovelace"
        description="Mathematician, 1815–1852"
        trigger={<PlTextLink href="#ada">Ada Lovelace</PlTextLink>}
      >
        Wrote the first algorithm intended to be carried out by a machine, in a set of notes longer
        than the paper they annotated.
      </PlHoverCard>
      , and are longer than the paper.
    </p>
  );
}
