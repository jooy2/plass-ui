import { useState } from 'react';
import {
  PlAccordion,
  PlAccordionItem,
  PlAppLogo,
  PlAspectRatio,
  PlAvatar,
  PlBlockquote,
  PlButton,
  PlCard,
  PlCarousel,
  PlChip,
  PlContainer,
  PlDivider,
  PlGrid,
  PlGridItem,
  PlIcon,
  PlRating,
  PlSegment,
  PlSegmentedButton,
  PlTab,
  PlTabPanel,
  PlTabs,
  PlTextField,
  PlTextLink,
  PlToolbar,
  PlTypography
} from 'plass-ui';

/**
 * The marketing page of Halyard, a product that does not exist.
 *
 * A landing page is where a component library is asked the opposite question
 * from an app: not "can this hold a table of six hundred rows" but "can these
 * parts make one page that somebody wants to read". Everything here is a
 * released component — the only hand-written CSS is the layout between them.
 */

/* ---------------------------------------------------------------------------
 * Glyphs
 * ------------------------------------------------------------------------- */

const stroke = {
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.7,
  strokeLinecap: 'round',
  strokeLinejoin: 'round'
} as const;

const BoltGlyph = () => (
  <svg {...stroke}>
    <path d="M13 2 4 14h7l-1 8 9-12h-7Z" />
  </svg>
);

const ShieldGlyph = () => (
  <svg {...stroke}>
    <path d="M12 3.2 19 6v5.5c0 4-3 7.2-7 8.8-4-1.6-7-4.8-7-8.8V6Z" />
    <path d="m9 12 2.2 2.2L15.5 10" />
  </svg>
);

const PlugGlyph = () => (
  <svg {...stroke}>
    <path d="M9 3v5M15 3v5M6 8h12v3a6 6 0 0 1-12 0Z" />
    <path d="M12 17v4" />
  </svg>
);

const ChartGlyph = () => (
  <svg {...stroke}>
    <path d="M4 20V4M4 20h16M8 17v-5M12.5 17V8M17 17v-3" />
  </svg>
);

const CheckGlyph = () => (
  <svg {...stroke}>
    <path d="m5 12.5 4.5 4.5L19 7" />
  </svg>
);

/* ---------------------------------------------------------------------------
 * The content
 * ------------------------------------------------------------------------- */

const FEATURES = [
  {
    icon: <BoltGlyph />,
    color: 'warning' as const,
    title: 'Ships in a week',
    body: 'Point it at a repository and it opens the first pull request the same afternoon.'
  },
  {
    icon: <ShieldGlyph />,
    color: 'success' as const,
    title: 'Audited by default',
    body: 'Every change is signed, and the log is one table you can hand to a reviewer.'
  },
  {
    icon: <PlugGlyph />,
    color: 'info' as const,
    title: 'Forty connectors',
    body: 'The tools you already pay for, wired up without a script anybody has to keep.'
  },
  {
    icon: <ChartGlyph />,
    color: 'primary' as const,
    title: 'Numbers, not vibes',
    body: 'What changed, what it cost and what it saved — on one screen, updated hourly.'
  }
];

const VOICES = [
  {
    quote:
      'We replaced four scripts and a spreadsheet with one screen, and the handover to the new team took an afternoon.',
    name: 'Nadia Rowan',
    role: 'Head of Platform, Northwind',
    portrait: '/samples/avatars/nadia-rowan.webp'
  },
  {
    quote:
      'The audit log was the thing that sold it. Our reviewer stopped asking for exports in the second week.',
    name: 'Theo Quinn',
    role: 'Engineering Manager, Globex',
    portrait: '/samples/avatars/theo-quinn.webp'
  },
  {
    quote:
      'It is the first tool in years that our designers and our on-call rota both open every day.',
    name: 'Victor Saye',
    role: 'CTO, Initech',
    portrait: undefined
  }
];

const PLANS = [
  {
    name: 'Solo',
    monthly: 12,
    blurb: 'One person, one repository.',
    perks: ['Unlimited runs', 'Seven-day history', 'Community support'],
    featured: false
  },
  {
    name: 'Team',
    monthly: 32,
    blurb: 'The one nearly everybody picks.',
    perks: ['Everything in Solo', 'Ninety-day history', 'Audit log and SSO', 'Priority support'],
    featured: true
  },
  {
    name: 'Company',
    monthly: 68,
    blurb: 'When procurement gets involved.',
    perks: ['Everything in Team', 'Unlimited history', 'Custom retention', 'A named engineer'],
    featured: false
  }
];

export default function LandingExample() {
  const [cycle, setCycle] = useState<string | number | null>('yearly');
  const [email, setEmail] = useState('');
  const [signed, setSigned] = useState(false);

  const yearly = cycle === 'yearly';

  return (
    <div className="@container/page w-full overflow-hidden rounded-(--plass-radius-lg) border [border-color:var(--plass-border)] bg-(--plass-glass)">
      <PlToolbar
        size="sm"
        position="sticky"
        render={<header />}
        start={<PlAppLogo size="sm" name="Halyard" src="/samples/marks/kite.webp" />}
        end={
          <>
            <nav className="hidden items-center gap-4 @2xl/page:flex" aria-label="Sections">
              <PlTextLink href="#features" color="secondary" underline="hover">
                Features
              </PlTextLink>
              <PlTextLink href="#pricing" color="secondary" underline="hover">
                Pricing
              </PlTextLink>
              <PlTextLink href="#faq" color="secondary" underline="hover">
                FAQ
              </PlTextLink>
            </nav>
            <PlButton size="sm">Start free</PlButton>
          </>
        }
      />

      {/* ------------------------------------------------------------------ */}
      {/* Hero                                                                */}
      {/* ------------------------------------------------------------------ */}
      <PlContainer maxWidth="lg" render={<section />}>
        <div className="flex flex-col items-center gap-5 py-12 text-center">
          <PlChip size="sm" variant="ghost" color="info">
            New · Scheduled runs
          </PlChip>

          <PlTypography level="h1" className="max-w-2xl text-balance">
            Every deploy, written down before anyone has to ask
          </PlTypography>

          <PlTypography level="lead" className="max-w-xl text-balance">
            Halyard watches what your team ships and turns it into a record you can read, search and
            hand to whoever needs it next.
          </PlTypography>

          <div className="flex flex-wrap items-center justify-center gap-3">
            <PlButton size="lg">Start free</PlButton>
            <PlButton size="lg" variant="glass" color="secondary">
              Book a walkthrough
            </PlButton>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-3">
            <div className="flex -space-x-2">
              {VOICES.map((voice) => (
                <PlAvatar
                  key={voice.name}
                  size="sm"
                  name={voice.name}
                  src={voice.portrait}
                  className="ring-2 ring-(--plass-surface)"
                />
              ))}
            </div>
            <PlRating size="sm" value={4.5} precision={0.5} readOnly />
            <span className="text-sm text-(--plass-muted-fg)">
              4.5 from 210 teams on the usual review sites
            </span>
          </div>
        </div>
      </PlContainer>

      {/* ------------------------------------------------------------------ */}
      {/* The product, in three views                                         */}
      {/* ------------------------------------------------------------------ */}
      <PlContainer maxWidth="lg" render={<section />}>
        <PlTabs defaultValue="timeline" fullWidth className="pb-12">
          <PlTab value="timeline">Timeline</PlTab>
          <PlTab value="review">Review</PlTab>
          <PlTab value="report">Report</PlTab>

          {[
            { value: 'timeline', label: 'timeline', from: 'primary', to: 'info' },
            { value: 'review', label: 'review queue', from: 'success', to: 'primary' },
            { value: 'report', label: 'monthly report', from: 'info', to: 'warning' }
          ].map((view) => (
            <PlTabPanel key={view.value} value={view.value}>
              <PlAspectRatio ratio="16 / 7" rounded size="lg">
                <div
                  className="flex size-full items-end p-5"
                  style={{
                    backgroundImage: `linear-gradient(135deg, var(--plass-${view.from}-solid), var(--plass-${view.to}-solid))`
                  }}
                >
                  <span className="text-sm font-semibold text-white">
                    The {view.label}, in the product
                  </span>
                </div>
              </PlAspectRatio>
            </PlTabPanel>
          ))}
        </PlTabs>
      </PlContainer>

      {/* ------------------------------------------------------------------ */}
      {/* Features                                                            */}
      {/* ------------------------------------------------------------------ */}
      <div id="features" className="bg-(--plass-glass-press) py-12">
        <PlContainer maxWidth="lg" render={<section />}>
          <div className="mb-8 flex flex-col items-center gap-2 text-center">
            <PlTypography level="overline">What you get</PlTypography>
            <PlTypography level="h3">Four things, and none of them a dashboard</PlTypography>
          </div>

          <PlGrid spacing={3}>
            {FEATURES.map((feature) => (
              <PlGridItem key={feature.title} span={{ xs: 12, sm: 6, lg: 3 }}>
                <PlCard className="h-full" elevation={1}>
                  <div className="flex flex-col gap-3">
                    <PlIcon size="lg" color={feature.color} icon={feature.icon} />
                    <PlTypography level="h6">{feature.title}</PlTypography>
                    <PlTypography level="body" className="text-(--plass-muted-fg)">
                      {feature.body}
                    </PlTypography>
                  </div>
                </PlCard>
              </PlGridItem>
            ))}
          </PlGrid>
        </PlContainer>
      </div>

      {/* ------------------------------------------------------------------ */}
      {/* Voices                                                              */}
      {/* ------------------------------------------------------------------ */}
      <PlContainer maxWidth="md" render={<section />}>
        <div className="py-12">
          {/* The carousel's arrows sit over the slide's edges, so a slide has to
              leave them room — otherwise the first word of every quote is under
              a button. */}
          <PlCarousel label="What people say" loop>
            {VOICES.map((voice) => (
              <div key={voice.name} className="px-10 py-2">
                <PlBlockquote size="lg" variant="glass" author={voice.name} source={voice.role}>
                  {voice.quote}
                </PlBlockquote>
              </div>
            ))}
          </PlCarousel>
        </div>
      </PlContainer>

      {/* ------------------------------------------------------------------ */}
      {/* Pricing                                                             */}
      {/* ------------------------------------------------------------------ */}
      <div id="pricing" className="bg-(--plass-glass-press) py-12">
        <PlContainer maxWidth="lg" render={<section />}>
          <div className="mb-8 flex flex-col items-center gap-4 text-center">
            <PlTypography level="h3">Priced per person, billed how you like</PlTypography>
            <PlSegmentedButton value={cycle} onValueChange={setCycle} aria-label="Billing cycle">
              <PlSegment value="monthly">Monthly</PlSegment>
              <PlSegment value="yearly">Yearly · save 20%</PlSegment>
            </PlSegmentedButton>
          </div>

          <PlGrid spacing={3}>
            {PLANS.map((plan) => (
              <PlGridItem key={plan.name} span={{ xs: 12, md: 4 }}>
                <PlCard
                  className="h-full"
                  elevation={plan.featured ? 3 : 1}
                  color={plan.featured ? 'primary' : 'secondary'}
                  title={plan.name}
                  subtitle={plan.blurb}
                  headerAction={
                    plan.featured ? (
                      <PlChip size="xs" color="primary">
                        Popular
                      </PlChip>
                    ) : null
                  }
                  footer={
                    <PlButton
                      fullWidth
                      variant={plan.featured ? 'solid' : 'glass'}
                      color={plan.featured ? 'primary' : 'secondary'}
                    >
                      Choose {plan.name}
                    </PlButton>
                  }
                >
                  <div className="flex flex-col gap-4">
                    <div className="flex items-baseline gap-1">
                      <PlTypography level="h2">
                        £{yearly ? Math.round(plan.monthly * 0.8) : plan.monthly}
                      </PlTypography>
                      <span className="text-sm text-(--plass-muted-fg)">per person / month</span>
                    </div>

                    <ul className="flex flex-col gap-2">
                      {plan.perks.map((perk) => (
                        <li key={perk} className="flex items-start gap-2 text-sm">
                          <PlIcon size="sm" color="success" icon={<CheckGlyph />} />
                          <span>{perk}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </PlCard>
              </PlGridItem>
            ))}
          </PlGrid>
        </PlContainer>
      </div>

      {/* ------------------------------------------------------------------ */}
      {/* FAQ                                                                 */}
      {/* ------------------------------------------------------------------ */}
      <PlContainer maxWidth="md" render={<section />}>
        <div id="faq" className="flex flex-col gap-6 py-12">
          <PlTypography level="h3" className="text-center">
            Asked often enough to write down
          </PlTypography>

          <PlAccordion defaultValue={['data']}>
            <PlAccordionItem value="data" title="Where does our data sit?">
              In the region you pick when you sign up, and nowhere else. Backups stay in that region
              too.
            </PlAccordionItem>
            <PlAccordionItem value="trial" title="What happens after the trial?">
              Nothing, unless you add a card. The account goes read-only and the record stays where
              it is.
            </PlAccordionItem>
            <PlAccordionItem value="leave" title="Can we take the record with us?">
              Every screen has an export, and the API returns the same rows. Nothing here is a
              format only we can read.
            </PlAccordionItem>
            <PlAccordionItem value="support" title="Who answers when something breaks?">
              An engineer who works on Halyard, within a working day — and within an hour on Team
              and above.
            </PlAccordionItem>
          </PlAccordion>
        </div>
      </PlContainer>

      {/* ------------------------------------------------------------------ */}
      {/* Sign-up strip                                                       */}
      {/* ------------------------------------------------------------------ */}
      <div className="bg-(--plass-glass-press) py-12">
        <PlContainer maxWidth="sm" render={<section />}>
          <div className="flex flex-col items-center gap-4 text-center">
            <PlTypography level="h4">Start with one repository</PlTypography>
            <PlTypography level="body" className="text-(--plass-muted-fg)">
              Fourteen days, no card, and the record is yours whether you stay or not.
            </PlTypography>

            <form
              className="flex w-full max-w-md flex-col gap-2 @md/page:flex-row"
              onSubmit={(event) => {
                event.preventDefault();
                setSigned(true);
              }}
            >
              <PlTextField
                fullWidth
                type="email"
                required
                aria-label="Work email"
                placeholder="you@company.com"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
              />
              <PlButton type="submit">Start free</PlButton>
            </form>

            <p className="text-xs text-(--plass-muted-fg)">
              {signed ? (
                <span className="font-semibold text-(--plass-success-accent)">
                  Check {email || 'your inbox'} for the link.
                </span>
              ) : (
                <>
                  By starting you agree to the{' '}
                  <PlTextLink href="#terms" size="sm">
                    terms
                  </PlTextLink>
                  .
                </>
              )}
            </p>
          </div>
        </PlContainer>
      </div>

      {/* ------------------------------------------------------------------ */}
      {/* Footer                                                              */}
      {/* ------------------------------------------------------------------ */}
      <PlContainer maxWidth="lg" render={<footer />}>
        <div className="py-8">
          <PlDivider size="xs" />
          <div className="flex flex-wrap items-center justify-between gap-4 pt-6">
            <span className="text-sm text-(--plass-muted-fg)">© Halyard Ltd</span>
            <div className="flex flex-wrap gap-4">
              {['Privacy', 'Terms', 'Status', 'Careers'].map((item) => (
                <PlTextLink key={item} href="#footer" size="sm" color="secondary" underline="hover">
                  {item}
                </PlTextLink>
              ))}
            </div>
          </div>
        </div>
      </PlContainer>
    </div>
  );
}
