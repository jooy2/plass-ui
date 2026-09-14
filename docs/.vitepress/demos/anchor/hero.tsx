import { useRef } from 'react';
import { PlAnchor, type PlAnchorItem } from 'plass-ui';

const sections = [
  { id: 'overview', title: 'Overview', depth: 0 },
  { id: 'install', title: 'Install', depth: 0 },
  { id: 'options', title: 'Options', depth: 1 },
  { id: 'troubleshooting', title: 'Troubleshooting', depth: 0 }
];

const items: PlAnchorItem[] = sections.map((section) => ({
  href: `#anchor-demo-${section.id}`,
  label: section.title,
  depth: section.depth
}));

/**
 * The preview scrolls a box of its own rather than the page, so the demo works
 * inside the documentation, and `target` points the list at that box.
 *
 * A press scrolls the box itself. The documentation site catches every link to
 * a fragment on its own page and scrolls the window to it, which would move the
 * whole page to bring a heading inside the box to its top.
 */
export default function AnchorHero() {
  const scroller = useRef<HTMLDivElement>(null);

  return (
    <div className="flex w-full max-w-2xl gap-6">
      <PlAnchor
        className="w-44 shrink-0"
        items={items}
        target={scroller}
        label="On this page"
        onSelect={(item, event) => {
          const box = scroller.current;
          const heading = document.getElementById(item.href.slice(1));

          if (!box || !heading) return;

          event.preventDefault();
          box.scrollTo({
            top:
              box.scrollTop + heading.getBoundingClientRect().top - box.getBoundingClientRect().top,
            behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches
              ? 'auto'
              : 'smooth'
          });
        }}
      />

      <div ref={scroller} className="h-72 flex-1 overflow-y-auto pe-2">
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
