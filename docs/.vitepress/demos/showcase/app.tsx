import { useState } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlAlert,
  PlAvatar,
  PlBadge,
  PlBlockquote,
  PlBreadcrumb,
  PlBreadcrumbItem,
  PlButton,
  PlCard,
  PlCheckbox,
  PlChip,
  PlDivider,
  PlFilePicker,
  PlHighlight,
  PlHotKeys,
  PlIcon,
  PlList,
  PlListItem,
  PlModal,
  PlModalClose,
  PlPagination,
  PlRadio,
  PlRadioGroup,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlSkeleton,
  PlSlider,
  PlSwitch,
  PlTab,
  PlTabPanel,
  PlTable,
  PlTabs,
  PlTextField,
  PlTextLink,
  PlTimeline,
  PlTimelineItem,
  PlTypography
} from 'plass-ui';

/**
 * Every component the library has, on one screen.
 *
 * This is the page that has to be updated when a component is added, and the
 * reason it exists is that a component page shows a control on its own and a
 * screen shows it next to the others: a PlButton and a PlTextField of the same
 * `size` sitting on the same row is the only place the shared height ladder is
 * actually visible.
 */
function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
      <circle cx="7" cy="7" r="4.5" />
      <path d="m10.5 10.5 3 3" strokeLinecap="round" />
    </svg>
  );
}

function BoltIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
      <path d="M13 2 4 14h7l-1 8 9-12h-7Z" strokeLinejoin="round" />
    </svg>
  );
}

export default function ShowcaseApp() {
  const [name, setName] = useState('Acme Inc');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  function save() {
    setSaving(true);
    setSaved(false);
    window.setTimeout(() => {
      setSaving(false);
      setSaved(true);
    }, 900);
  }

  return (
    <div className="flex flex-col gap-4">
      <PlBreadcrumb size="sm">
        <PlBreadcrumbItem href="#showcase">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem href="#showcase">Organisation</PlBreadcrumbItem>
        <PlBreadcrumbItem>Settings</PlBreadcrumbItem>
      </PlBreadcrumb>

      <div className="flex flex-wrap items-center gap-3">
        <PlBadge dot color="success" overlap="circle" label="Online">
          <PlAvatar name="Ada Lovelace" src="/portrait-1.svg" />
        </PlBadge>
        <PlTextField
          size="md"
          placeholder="Search settings"
          startIcon={<SearchIcon />}
          endIcon={<PlHotKeys size="xs" keys="Mod+K" />}
          className="grow"
        />
        <PlSegmentedButton size="md" aria-label="Layout" defaultValue="grid">
          <PlSegment value="grid">Grid</PlSegment>
          <PlSegment value="list">List</PlSegment>
        </PlSegmentedButton>
        <PlButton size="md">New</PlButton>
      </div>

      <PlAlert
        color="warning"
        icon={<PlIcon size="sm" icon={<BoltIcon />} />}
        title="Your card expires next month"
      >
        Update it before the 30th or the next invoice will fail.
      </PlAlert>

      <div className="grid gap-4 md:grid-cols-2">
        <PlCard title="Organisation" elevation={2} render={<section />}>
          <div className="flex flex-col gap-4">
            <PlTextField
              fullWidth
              label="Name"
              value={name}
              description="Shown on invoices."
              onChange={(event) => setName(event.target.value)}
            />
            <PlTextField
              fullWidth
              label="Billing email"
              type="email"
              defaultValue="billing@"
              error="Enter a valid address."
            />
            <PlSelect
              fullWidth
              label="Plan"
              items={[
                { value: 'starter', label: 'Starter' },
                { value: 'team', label: 'Team' },
                { value: 'enterprise', label: 'Enterprise' }
              ]}
              defaultValue="team"
            />
            <PlFilePicker
              size="sm"
              label="Company logo"
              accept="image/*"
              title="Drop a logo, or click to browse"
              hint="PNG or SVG"
            />
            <PlRadioGroup label="Billing cycle" orientation="horizontal" defaultValue="yearly">
              <PlRadio value="monthly" label="Monthly" />
              <PlRadio value="yearly" label="Yearly" />
            </PlRadioGroup>
            <PlCheckbox label="Send me the monthly invoice by email" defaultChecked />
            <p className="text-xs text-(--plass-muted-fg)">
              <PlHighlight query="annually" color="info" variant="ghost">
                Invoices are issued annually.
              </PlHighlight>{' '}
              Charges follow the{' '}
              <PlTextLink href="#showcase" color="primary">
                billing terms
              </PlTextLink>
              .
            </p>
            <PlSwitch className="w-full" labelPlacement="start" label="Public profile" />
            <PlDivider size="xs">Then</PlDivider>
            <div className="flex items-center gap-3">
              <PlButton loading={saving} onClick={save}>
                {saving ? 'Saving' : 'Save changes'}
              </PlButton>
              <PlButton variant="ghost" color="secondary">
                Discard
              </PlButton>
              {saved ? (
                <span className="text-xs font-semibold text-(--plass-success-accent)">Saved</span>
              ) : null}
            </div>
          </div>
        </PlCard>

        <PlCard title="Members" elevation={2} render={<section />}>
          <PlList variant="ghost" size="sm" dividers>
            <PlListItem
              startIcon={<PlAvatar size="xs" name="Ada Lovelace" src="/portrait-1.svg" />}
              description="Owner"
              action={<PlSwitch size="sm" defaultChecked aria-label="Notify Ada" />}
            >
              Ada Lovelace
            </PlListItem>
            <PlListItem
              startIcon={<PlAvatar size="xs" name="Grace Hopper" />}
              description="Admin"
              action={<PlSwitch size="sm" aria-label="Notify Grace" />}
            >
              Grace Hopper
            </PlListItem>
            <PlListItem
              startIcon={<PlSkeleton shape="circle" size="xs" />}
              description={<PlSkeleton size="xs" width={90} />}
            >
              <PlSkeleton size="xs" width={130} label="Loading the fourth member" />
            </PlListItem>
          </PlList>
        </PlCard>

        <PlCard title="Danger zone" elevation={2} render={<section />}>
          <div className="flex flex-col gap-4">
            <PlTextField
              fullWidth
              variant="solid"
              label="Type the organisation name to confirm"
              placeholder={name}
            />
            <PlTextField
              fullWidth
              multiline
              rows={2}
              label="Why are you leaving?"
              variant="ghost"
            />
            <PlSlider
              label="Keep backups for"
              color="danger"
              defaultValue={30}
              min={0}
              max={90}
              step={5}
              showValue={(formatted) => `${formatted[0]} days`}
            />
            <div className="flex items-center gap-3">
              <PlModal
                size="sm"
                trigger={<PlButton color="danger">Delete organisation</PlButton>}
                title="Delete this organisation?"
                description="Every project, invoice and key goes with it."
                actions={
                  <>
                    <PlModalClose
                      render={
                        <PlButton variant="ghost" color="secondary">
                          Cancel
                        </PlButton>
                      }
                    />
                    <PlModalClose render={<PlButton color="danger">Delete</PlButton>} />
                  </>
                }
              />
              <PlButton variant="glass" color="secondary" readOnly>
                Export first
              </PlButton>
            </div>
          </div>
        </PlCard>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <PlChip size="sm" selected onClick={() => {}} count={12}>
          Unpaid
        </PlChip>
        <PlChip size="sm" onClick={() => {}} count={148}>
          Paid
        </PlChip>
        <PlChip size="sm" variant="ghost" color="secondary" onDelete={() => {}}>
          last 30 days
        </PlChip>
      </div>

      <PlTimeline size="sm" orientation="horizontal" active={2}>
        <PlTimelineItem title="Trial" bullet="1" />
        <PlTimelineItem title="Card added" bullet="2" />
        <PlTimelineItem title="First invoice" bullet="3" />
        <PlTimelineItem title="Renewal" bullet="4" />
      </PlTimeline>

      <PlTypography level="h5">Recent invoices</PlTypography>

      <PlTable
        size="sm"
        hoverable
        caption="Recent invoices"
        columns={[
          { key: 'id', header: 'Invoice', width: 110 },
          { key: 'customer', header: 'Customer' },
          { key: 'total', header: 'Total', align: 'end' }
        ]}
        rows={[
          { id: 'INV-0102', customer: 'Acme Inc', total: '$1,240.00' },
          { id: 'INV-0101', customer: 'Globex', total: '$340.50' }
        ]}
      />

      <div className="flex justify-center">
        <PlPagination size="sm" count={12} defaultPage={4} />
      </div>

      <PlTabs size="sm" defaultValue="activity">
        <PlTab value="activity">Activity</PlTab>
        <PlTab value="members" endIcon={<PlBadge size="xs" variant="ghost" content={4} />}>
          Members
        </PlTab>

        <PlTabPanel value="activity">Nothing has happened in the last seven days.</PlTabPanel>
        <PlTabPanel value="members">Four people, and what each of them can do.</PlTabPanel>
      </PlTabs>

      <PlBlockquote size="sm" variant="glass" author="The onboarding email">
        Keys are shown once, when they are created. Rotate one rather than sharing it.
      </PlBlockquote>

      <PlAccordion size="sm" defaultValue={['keys']}>
        <PlAccordionItem value="keys" title="API keys" subtitle="Two active">
          Keys are shown once, when they are created. Rotate one rather than sharing it.
        </PlAccordionItem>
        <PlAccordionItem value="webhooks" title="Webhooks" subtitle="None yet">
          Point a URL at an event and we will POST to it.
        </PlAccordionItem>
      </PlAccordion>
    </div>
  );
}
