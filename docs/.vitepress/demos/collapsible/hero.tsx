import { PlCollapsible } from 'plass-ui';

export default function CollapsibleHero() {
  return (
    <PlCollapsible className="w-full max-w-md" title="Advanced" subtitle="Nine settings">
      Everything a form does not need to ask on the first pass lives behind one of these, and the
      page does not grow until somebody asks for it.
    </PlCollapsible>
  );
}
