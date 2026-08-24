import { PlPagination } from 'plass-ui';

export default function PaginationLinks() {
  return (
    <div className="flex flex-col items-center gap-2">
      <PlPagination count={8} defaultPage={3} getPageHref={(page) => `#page-${page}`} />
      <p className="text-xs text-(--plass-muted-fg)">
        Every number is an <code>&lt;a href&gt;</code>. Hover one and the browser shows where it
        goes.
      </p>
    </div>
  );
}
