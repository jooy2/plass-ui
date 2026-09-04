import { useEffect, useState } from 'react';
import { PlAnchor, type PlAnchorItem } from 'plass-ui';

const sections = [
  { id: 'overview', title: 'Overview', depth: 0 },
  { id: 'install', title: 'Install', depth: 0 },
  { id: 'options', title: 'Options', depth: 1 },
  { id: 'troubleshooting', title: 'Troubleshooting', depth: 0 }
];

const items: PlAnchorItem[] = sections.map((section) => ({
  href: `#${section.id}`,
  label: section.title,
  depth: section.depth
}));

/**
 * The preview scrolls a box of its own rather than the page, so the demo works
 * inside the documentation. The component tracks the window, so the box is read
 * back into an `active` and handed to it.
 */
export default function AnchorHero() {
  const [active, setActive] = useState(items[0].href);

  useEffect(() => {
    const box = document.getElementById('anchor-demo-scroller');

    if (!box) return;

    const onScroll = () => {
      let current = items[0].href;

      for (const section of sections) {
        const heading = document.getElementById(`anchor-demo-${section.id}`);

        if (heading && heading.getBoundingClientRect().top - box.getBoundingClientRect().top <= 1) {
          current = `#${section.id}`;
        }
      }

      setActive(current);
    };

    box.addEventListener('scroll', onScroll, { passive: true });

    return () => box.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <div className="flex w-full max-w-2xl gap-6">
      <PlAnchor className="w-44 shrink-0" items={items} active={active} label="On this page" />

      <div id="anchor-demo-scroller" className="h-72 flex-1 overflow-y-auto pe-2">
        {sections.map((section) => (
          <div key={section.id}>
            <h3 id={`anchor-demo-${section.id}`} className="mb-2 text-lg font-semibold">
              {section.title}
            </h3>
            <p className="mb-8 text-sm text-(--plass-muted-fg)">
              Scroll the column on the right and the list beside it follows. What is lit is the last
              heading you passed, not whichever one happens to be on screen.
            </p>
            <div className="h-24" />
          </div>
        ))}
      </div>
    </div>
  );
}
