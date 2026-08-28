import { useMemo, useState } from 'react';
import {
  PlAlert,
  PlAvatar,
  PlBadge,
  PlBreadcrumb,
  PlBreadcrumbItem,
  PlButton,
  PlCard,
  PlCheckbox,
  PlChip,
  PlDateRangePicker,
  PlDivider,
  PlDrawer,
  PlDrawerClose,
  PlIcon,
  PlIconButton,
  PlList,
  PlListItem,
  PlMenu,
  PlMenuItem,
  PlMenuSeparator,
  PlModal,
  PlModalClose,
  PlPagination,
  PlPill,
  PlProgressCircular,
  PlProgressLinear,
  PlSelect,
  PlSegment,
  PlSegmentedButton,
  PlSwitch,
  PlTable,
  PlTextField,
  PlTimeline,
  PlTimelineItem,
  PlToastProvider,
  PlToolbar,
  PlTooltip,
  PlTypography,
  usePlToast,
  type PlTableColumn
} from 'plass-ui';

/**
 * The back office of Grange, a shop that does not exist.
 *
 * A rail, an app bar, four figures, a filter row and a table with an action on
 * every row — all on one screen and all at the same `size`, which is the
 * arrangement that shows whether a size ladder actually holds. The table is
 * live: search it, filter it, select rows and the bulk actions appear.
 */

/* ---------------------------------------------------------------------------
 * Glyphs
 *
 * Drawn here rather than imported, so the file a reader opens from the docs is
 * the whole thing. `PlIcon` gives them their size and colour.
 * ------------------------------------------------------------------------- */

const stroke = {
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.7,
  strokeLinecap: 'round',
  strokeLinejoin: 'round'
} as const;

const HomeGlyph = () => (
  <svg {...stroke}>
    <path d="M4 10.5 12 4l8 6.5V19a1 1 0 0 1-1 1h-4v-6H9v6H5a1 1 0 0 1-1-1Z" />
  </svg>
);

const OrdersGlyph = () => (
  <svg {...stroke}>
    <path d="M4 7h16v12a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1Z" />
    <path d="M8 7V5a4 4 0 0 1 8 0v2" />
  </svg>
);

const PeopleGlyph = () => (
  <svg {...stroke}>
    <circle cx="9" cy="8" r="3.2" />
    <path d="M3.5 19a5.5 5.5 0 0 1 11 0M16 6.2a3.2 3.2 0 0 1 0 5.6M17 14.4a5.5 5.5 0 0 1 3.5 4.6" />
  </svg>
);

const ChartGlyph = () => (
  <svg {...stroke}>
    <path d="M4 20V4M4 20h16M8 17V11M12.5 17V7M17 17v-4" />
  </svg>
);

const CogGlyph = () => (
  <svg {...stroke}>
    <circle cx="12" cy="12" r="3" />
    <path d="M12 3v2.2M12 18.8V21M4.6 7.8l1.9 1.1M17.5 15.1l1.9 1.1M4.6 16.2l1.9-1.1M17.5 8.9l1.9-1.1" />
  </svg>
);

const SearchGlyph = () => (
  <svg {...stroke}>
    <circle cx="11" cy="11" r="6" />
    <path d="m20 20-4.5-4.5" />
  </svg>
);

const BellGlyph = () => (
  <svg {...stroke}>
    <path d="M6 9a6 6 0 1 1 12 0c0 3.5 1 5 1.5 6h-15C5 14 6 12.5 6 9Z" />
    <path d="M10 19a2 2 0 0 0 4 0" />
  </svg>
);

const MoreGlyph = () => (
  <svg viewBox="0 0 24 24" fill="currentColor">
    <circle cx="5" cy="12" r="1.7" />
    <circle cx="12" cy="12" r="1.7" />
    <circle cx="19" cy="12" r="1.7" />
  </svg>
);

const SyncGlyph = () => <span className="block size-2 rounded-full bg-current" />;

const WarnGlyph = () => (
  <svg {...stroke}>
    <path d="M12 4.5 21 19.5H3Z" />
    <path d="M12 10v4M12 16.8v.2" />
  </svg>
);

/* ---------------------------------------------------------------------------
 * The data
 * ------------------------------------------------------------------------- */

type Status = 'paid' | 'pending' | 'refunded';

interface Order {
  id: string;
  customer: string;
  channel: string;
  status: Status;
  placed: string;
  total: number;
}

const ORDERS: Order[] = [
  { id: 'GR-4021', customer: 'Ada Lovelace', channel: 'web', status: 'paid', placed: '12 Mar', total: 248.0 }, // prettier-ignore
  { id: 'GR-4020', customer: 'Grace Hopper', channel: 'web', status: 'pending', placed: '12 Mar', total: 92.5 }, // prettier-ignore
  { id: 'GR-4019', customer: 'Alan Turing', channel: 'store', status: 'paid', placed: '11 Mar', total: 1310.0 }, // prettier-ignore
  { id: 'GR-4018', customer: 'Katherine Johnson', channel: 'phone', status: 'refunded', placed: '11 Mar', total: 74.25 }, // prettier-ignore
  { id: 'GR-4017', customer: 'Edsger Dijkstra', channel: 'web', status: 'paid', placed: '10 Mar', total: 512.4 }, // prettier-ignore
  { id: 'GR-4016', customer: 'Barbara Liskov', channel: 'store', status: 'paid', placed: '10 Mar', total: 188.0 } // prettier-ignore
];

const STATUS: Record<Status, { label: string; color: 'success' | 'warning' | 'danger' }> = {
  paid: { label: 'Paid', color: 'success' },
  pending: { label: 'Pending', color: 'warning' },
  refunded: { label: 'Refunded', color: 'danger' }
};

const money = new Intl.NumberFormat('en-GB', { style: 'currency', currency: 'GBP' });

const NAV = [
  { id: 'overview', label: 'Overview', icon: <HomeGlyph /> },
  { id: 'orders', label: 'Orders', icon: <OrdersGlyph />, count: 6 },
  { id: 'customers', label: 'Customers', icon: <PeopleGlyph /> },
  { id: 'reports', label: 'Reports', icon: <ChartGlyph /> },
  { id: 'settings', label: 'Settings', icon: <CogGlyph /> }
];

export default function DashboardExample() {
  return (
    <PlToastProvider position="bottom-end">
      <Dashboard />
    </PlToastProvider>
  );
}

function Dashboard() {
  const toast = usePlToast();
  const [where, setWhere] = useState('orders');
  const [query, setQuery] = useState('');
  const [channel, setChannel] = useState<string | number | null>('all');
  const [tab, setTab] = useState<string | number | null>('all');
  const [picked, setPicked] = useState<string[]>([]);
  const [page, setPage] = useState(1);

  const rows = useMemo(
    () =>
      ORDERS.filter((order) => {
        const matchesQuery =
          !query ||
          `${order.id} ${order.customer}`.toLowerCase().includes(query.trim().toLowerCase());
        const matchesChannel = channel === 'all' || order.channel === channel;
        const matchesTab = tab === 'all' || order.status === tab;

        return matchesQuery && matchesChannel && matchesTab;
      }),
    [query, channel, tab]
  );

  const allPicked = rows.length > 0 && picked.length === rows.length;

  function toggle(id: string) {
    setPicked((current) =>
      current.includes(id) ? current.filter((one) => one !== id) : [...current, id]
    );
  }

  const columns: PlTableColumn<Order>[] = [
    {
      key: 'pick',
      width: 44,
      header: (
        <PlCheckbox
          size="sm"
          aria-label="Select every order"
          checked={allPicked}
          indeterminate={picked.length > 0 && !allPicked}
          onCheckedChange={(next) => setPicked(next ? rows.map((row) => row.id) : [])}
        />
      ),
      render: (row) => (
        <PlCheckbox
          size="sm"
          aria-label={`Select ${row.id}`}
          checked={picked.includes(row.id)}
          onCheckedChange={() => toggle(row.id)}
        />
      )
    },
    { key: 'id', header: 'Order', width: 96 },
    { key: 'customer', header: 'Customer' },
    {
      key: 'status',
      header: 'Status',
      width: 108,
      render: (row) => (
        <PlChip size="xs" variant="ghost" color={STATUS[row.status].color}>
          {STATUS[row.status].label}
        </PlChip>
      )
    },
    { key: 'placed', header: 'Placed', width: 78 },
    {
      key: 'total',
      header: 'Total',
      align: 'end',
      width: 100,
      render: (row) => money.format(row.total)
    },
    {
      key: 'actions',
      header: '',
      align: 'end',
      width: 52,
      render: (row) => (
        <PlMenu
          trigger={
            <PlIconButton
              size="xs"
              variant="ghost"
              color="secondary"
              label={`Actions for ${row.id}`}
              icon={<MoreGlyph />}
            />
          }
        >
          <PlMenuItem onClick={() => toast.add({ color: 'info', title: `Opened ${row.id}` })}>
            Open
          </PlMenuItem>
          <PlMenuItem>Print invoice</PlMenuItem>
          <PlMenuSeparator />
          <PlMenuItem color="danger">Refund</PlMenuItem>
        </PlMenu>
      )
    }
  ];

  return (
    /* Container queries rather than `sm:`/`lg:`, and that is the one thing in
       this file that is about the docs rather than about the screen: a preview
       is laid out inside a column, and a viewport breakpoint would have this
       screen go four-up at 1280px however narrow the column holding it was. */
    <div className="@container/app flex w-full overflow-hidden rounded-(--plass-radius-lg) border [border-color:var(--plass-border)] bg-(--plass-glass)">
      {/* The rail. Gone on a narrow canvas, where the app bar is the whole
          navigation a phone would get. */}
      <aside className="hidden w-56 shrink-0 flex-col gap-4 border-e p-4 [border-color:var(--plass-divider)] @4xl/app:flex">
        <div className="flex items-center gap-2 px-1">
          <span className="size-6 rounded-(--plass-radius-sm) [background-image:linear-gradient(135deg,var(--plass-primary-solid),var(--plass-info-solid))]" />
          <PlTypography level="h6">Grange</PlTypography>
        </div>

        <PlList variant="ghost" size="sm" render={<nav aria-label="Sections" />}>
          {NAV.map((item) => (
            <PlListItem
              key={item.id}
              startIcon={<PlIcon size="sm" icon={item.icon} />}
              selected={where === item.id}
              onClick={() => setWhere(item.id)}
              endIcon={
                item.count ? <PlBadge size="xs" variant="ghost" content={item.count} /> : null
              }
            >
              {item.label}
            </PlListItem>
          ))}
        </PlList>

        <div className="mt-auto flex flex-col gap-3">
          <PlPill
            size="sm"
            color="success"
            title="Synced"
            description="2 minutes ago"
            startIcon={<SyncGlyph />}
          />
          <PlCard size="sm" title="Storage">
            <PlProgressLinear size="sm" label="14.2 GB of 20 GB" value={71} />
          </PlCard>
        </div>
      </aside>

      <div className="@container/main flex min-w-0 grow flex-col">
        <PlToolbar
          size="sm"
          position="sticky"
          render={<header />}
          start={
            <PlBreadcrumb size="sm" label="Where you are">
              <PlBreadcrumbItem href="#dashboard">Grange</PlBreadcrumbItem>
              <PlBreadcrumbItem>Orders</PlBreadcrumbItem>
            </PlBreadcrumb>
          }
          end={
            <>
              <PlTooltip content="What is new">
                <PlBadge dot color="danger" label="Three unread">
                  <PlIconButton
                    size="sm"
                    variant="ghost"
                    color="secondary"
                    label="Notifications"
                    icon={<BellGlyph />}
                  />
                </PlBadge>
              </PlTooltip>
              <SettingsDrawer />
              <PlAvatar size="sm" name="Ada Lovelace" src="/portrait-1.svg" />
            </>
          }
        />

        <div className="flex flex-col gap-4 p-4">
          <PlAlert
            color="warning"
            icon={<PlIcon size="sm" icon={<WarnGlyph />} />}
            title="Two payouts are on hold"
            action={
              <PlButton size="xs" variant="glass" color="warning">
                Review
              </PlButton>
            }
          >
            Your bank asked for one more document before the next transfer.
          </PlAlert>

          <div className="grid gap-3 @md/main:grid-cols-2 @3xl/main:grid-cols-4">
            <Figure title="Revenue" value="£38,204" delta="+12.4%" trend="up" progress={74} />
            <Figure title="Orders" value="1,284" delta="+3.1%" trend="up" progress={58} />
            <Figure title="Refund rate" value="1.9%" delta="−0.4pt" trend="up" progress={19} />
            <Figure title="Fulfilled" delta="−1.2pt" trend="down" ring={96} />
          </div>

          <PlCard elevation={1} padded={false} render={<section />}>
            <div className="flex flex-wrap items-end gap-3 p-4">
              <PlTextField
                size="sm"
                className="min-w-48 grow"
                placeholder="Search orders"
                aria-label="Search orders"
                startIcon={<SearchGlyph />}
                value={query}
                onChange={(event) => setQuery(event.target.value)}
              />
              <PlSelect
                size="sm"
                className="w-36"
                aria-label="Channel"
                value={channel}
                onValueChange={setChannel}
                items={[
                  { value: 'all', label: 'Every channel' },
                  { value: 'web', label: 'Web' },
                  { value: 'store', label: 'Store' },
                  { value: 'phone', label: 'Phone' }
                ]}
              />
              <PlDateRangePicker size="sm" startPlaceholder="From" endPlaceholder="To" clearable />
            </div>

            <PlDivider size="xs" />

            <div className="flex flex-wrap items-center justify-between gap-3 px-4 pt-3">
              {/* A segmented button rather than tabs: nothing here is a panel,
                  the table below is the same table either way, and this is a
                  filter — one value out of four. */}
              <PlSegmentedButton
                size="sm"
                aria-label="Filter by status"
                value={tab}
                onValueChange={(next) => {
                  setTab(next);
                  setPicked([]);
                }}
              >
                <PlSegment value="all">All</PlSegment>
                <PlSegment value="paid">Paid</PlSegment>
                <PlSegment value="pending">Pending</PlSegment>
                <PlSegment value="refunded">Refunded</PlSegment>
              </PlSegmentedButton>

              {picked.length > 0 ? (
                <div className="flex items-center gap-2">
                  <span className="text-xs text-(--plass-muted-fg)">{picked.length} selected</span>
                  <PlButton
                    size="xs"
                    variant="glass"
                    color="secondary"
                    onClick={() => {
                      toast.add({ color: 'success', title: `Marked ${picked.length} as shipped` });
                      setPicked([]);
                    }}
                  >
                    Mark shipped
                  </PlButton>
                  <PlModal
                    size="sm"
                    modal="trap-focus"
                    trigger={
                      <PlButton size="xs" color="danger">
                        Refund
                      </PlButton>
                    }
                    title={`Refund ${picked.length} orders?`}
                    description="The money goes back the way it came, and this cannot be undone."
                    actions={
                      <>
                        <PlModalClose
                          render={
                            <PlButton size="sm" variant="ghost" color="secondary">
                              Cancel
                            </PlButton>
                          }
                        />
                        <PlModalClose
                          render={
                            <PlButton
                              size="sm"
                              color="danger"
                              onClick={() => {
                                toast.add({
                                  color: 'danger',
                                  title: `Refunded ${picked.length} orders`,
                                  actionLabel: 'Undo',
                                  onAction: () => toast.add({ color: 'info', title: 'Restored' })
                                });
                                setPicked([]);
                              }}
                            >
                              Refund
                            </PlButton>
                          }
                        />
                      </>
                    }
                  />
                </div>
              ) : null}
            </div>

            <div className="p-4 pt-3">
              <PlTable
                size="sm"
                hoverable
                caption="Orders, most recent first"
                columns={columns}
                rows={rows}
                getRowKey={(row) => row.id}
                empty="No order matches those filters."
              />
            </div>

            <div className="flex justify-center pb-4">
              <PlPagination size="sm" count={9} page={page} onPageChange={setPage} />
            </div>
          </PlCard>

          <div className="grid gap-3 @2xl/main:grid-cols-2">
            <PlCard title="Today" subtitle="What happened" elevation={1} render={<section />}>
              <PlTimeline size="sm" active={2}>
                <PlTimelineItem title="Payout sent" meta="08:10" bullet="£">
                  £12,400 to the business account.
                </PlTimelineItem>
                <PlTimelineItem title="Stock reconciled" meta="10:32" />
                <PlTimelineItem title="Two payouts held" meta="11:04" color="warning" />
                <PlTimelineItem title="Weekly report" meta="18:00" status="upcoming" />
              </PlTimeline>
            </PlCard>

            <PlCard
              title="Notifications"
              subtitle="What reaches you"
              elevation={1}
              render={<section />}
            >
              <div className="flex flex-col gap-3">
                <PlSwitch
                  className="w-full"
                  size="sm"
                  labelPlacement="start"
                  label="A refund is requested"
                  defaultChecked
                />
                <PlSwitch
                  className="w-full"
                  size="sm"
                  labelPlacement="start"
                  label="Stock falls below ten"
                  defaultChecked
                />
                <PlSwitch
                  className="w-full"
                  size="sm"
                  labelPlacement="start"
                  label="A payout is held"
                />
                <PlDivider size="xs" />
                <PlProgressLinear size="sm" label="Monthly email quota" value={38} showValue />
              </div>
            </PlCard>
          </div>
        </div>
      </div>
    </div>
  );
}

/**
 * One figure.
 *
 * Two shapes, and which one it takes is decided by what the number *is*: a
 * count with a bar under it for progress towards a target, and a ring where the
 * figure is already a share of a whole and the ring can be the figure itself.
 */
function Figure({
  title,
  value,
  delta,
  trend,
  progress,
  ring
}: {
  title: string;
  value?: string;
  delta: string;
  trend: 'up' | 'down';
  progress?: number;
  ring?: number;
}) {
  const movement = (
    <span
      className={
        trend === 'up'
          ? 'text-xs font-semibold text-(--plass-success-accent)'
          : 'text-xs font-semibold text-(--plass-danger-accent)'
      }
    >
      {delta}
    </span>
  );

  const name = (
    <span className="text-xs font-semibold tracking-wide text-(--plass-muted-fg) uppercase">
      {title}
    </span>
  );

  if (ring !== undefined) {
    return (
      <PlCard size="sm" elevation={1}>
        <div className="flex items-center gap-3">
          {/* `showValue` writes the percentage beside the ring, so the ring is
              the figure and there is no number to repeat. `label` would print a
              second name next to the card's own, hence the bare `aria-label`. */}
          <PlProgressCircular size="xl" value={ring} showValue aria-label={title} />
          <div className="flex min-w-0 flex-col gap-1">
            {name}
            {movement}
          </div>
        </div>
      </PlCard>
    );
  }

  return (
    <PlCard size="sm" elevation={1}>
      <div className="flex min-w-0 flex-col gap-1">
        {name}
        <PlTypography level="h4">{value}</PlTypography>
        {movement}
      </div>
      {progress === undefined ? null : (
        <PlProgressLinear
          className="mt-3"
          size="xs"
          value={progress}
          label={`${title} to target`}
        />
      )}
    </PlCard>
  );
}

/** The settings that do not belong on the screen, in the sheet that slides over it. */
function SettingsDrawer() {
  return (
    <PlDrawer
      side="right"
      modal="trap-focus"
      trigger={
        <PlIconButton
          size="sm"
          variant="ghost"
          color="secondary"
          label="Table settings"
          icon={<CogGlyph />}
        />
      }
      title="Table settings"
      description="How this list is put together"
      actions={
        <>
          <PlDrawerClose
            render={
              <PlButton size="sm" variant="ghost" color="secondary">
                Cancel
              </PlButton>
            }
          />
          <PlDrawerClose render={<PlButton size="sm">Apply</PlButton>} />
        </>
      }
    >
      <div className="flex flex-col gap-4">
        <PlSelect
          fullWidth
          size="sm"
          label="Rows per page"
          defaultValue="25"
          items={[
            { value: '10', label: '10' },
            { value: '25', label: '25' },
            { value: '50', label: '50' }
          ]}
        />
        <PlDivider size="xs">Columns</PlDivider>
        <PlSwitch size="sm" label="Channel" defaultChecked />
        <PlSwitch size="sm" label="Placed" defaultChecked />
        <PlSwitch size="sm" label="Fulfilment" />
      </div>
    </PlDrawer>
  );
}
