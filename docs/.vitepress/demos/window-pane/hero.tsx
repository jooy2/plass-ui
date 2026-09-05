import { PlWindowPane } from 'plass-ui';

export default function WindowPaneHero() {
  return (
    <PlWindowPane title="alpine-lake-dawn.webp" draggable resizable width={420} height={280}>
      <figure className="m-0 flex h-full flex-col">
        <img
          src="/samples/photos/alpine-lake-dawn.webp"
          alt="A still mountain lake at first light"
          className="min-h-0 w-full flex-1 object-cover"
        />
        <figcaption className="border-t border-(--plass-border) p-3 text-xs text-(--plass-muted-fg)">
          Drag the bar, or take a corner. Minimize rolls the window up to its bar, because a page
          has nowhere to send it.
        </figcaption>
      </figure>
    </PlWindowPane>
  );
}
