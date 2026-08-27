import { PlDrawer, PlList, PlListItem } from 'plass-ui';

export default function DrawerInline() {
  return (
    <div className="flex h-64 w-full overflow-hidden rounded-(--plass-radius-lg) bg-(--plass-glass-press)">
      <PlDrawer mode="inline" size="sm" title="Sections" extent={200}>
        <PlList variant="ghost" size="sm">
          <PlListItem>Overview</PlListItem>
          <PlListItem>Members</PlListItem>
          <PlListItem>Billing</PlListItem>
        </PlList>
      </PlDrawer>

      <div className="flex-1 p-6 text-sm text-(--plass-muted-fg)">
        The page is laid out around it: no scrim, no portal, no focus trap, nothing to dismiss.
      </div>
    </div>
  );
}
