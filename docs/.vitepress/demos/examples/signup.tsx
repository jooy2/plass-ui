import { useState } from 'react';
import {
  PlAlert,
  PlAppLogo,
  PlAvatar,
  PlBlockquote,
  PlButton,
  PlCard,
  PlCheckbox,
  PlCombobox,
  PlDatePicker,
  PlDivider,
  PlFilePicker,
  PlIcon,
  PlList,
  PlListItem,
  PlOtpField,
  PlPopover,
  PlProgressLinear,
  PlRadio,
  PlRadioGroup,
  PlSwitch,
  PlTextField,
  PlTextLink,
  PlTimeline,
  PlTimelineItem,
  PlTypography
} from 'plass-ui';

/**
 * Signing up for Halyard, in three steps and one column.
 *
 * A form is where a component library either holds together or does not: every
 * control on this page is a different component, and they have to agree about
 * height, about where a label sits, about what an error looks like and about
 * which of them owns the focus ring. Nothing here is styled by hand.
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

const MailGlyph = () => (
  <svg {...stroke}>
    <rect x="3" y="5.5" width="18" height="13" rx="2" />
    <path d="m3.8 7 8.2 6 8.2-6" />
  </svg>
);

const LockGlyph = () => (
  <svg {...stroke}>
    <rect x="4.5" y="10" width="15" height="10" rx="2" />
    <path d="M8 10V7.5a4 4 0 0 1 8 0V10" />
  </svg>
);

const CheckGlyph = () => (
  <svg {...stroke}>
    <path d="m5 12.5 4.5 4.5L19 7" />
  </svg>
);

const GithubGlyph = () => (
  <svg viewBox="0 0 24 24" fill="currentColor">
    <path d="M12 2a10 10 0 0 0-3.16 19.49c.5.09.68-.22.68-.48v-1.7c-2.78.6-3.37-1.34-3.37-1.34-.45-1.15-1.11-1.46-1.11-1.46-.91-.62.07-.61.07-.61 1 .07 1.53 1.03 1.53 1.03.9 1.53 2.36 1.09 2.94.83.09-.65.35-1.09.63-1.34-2.22-.25-4.56-1.11-4.56-4.94 0-1.09.39-1.98 1.03-2.68-.1-.25-.45-1.27.1-2.65 0 0 .84-.27 2.75 1.02a9.5 9.5 0 0 1 5 0c1.91-1.29 2.75-1.02 2.75-1.02.55 1.38.2 2.4.1 2.65.64.7 1.03 1.59 1.03 2.68 0 3.84-2.34 4.69-4.57 4.94.36.31.68.92.68 1.85v2.74c0 .27.18.58.69.48A10 10 0 0 0 12 2Z" />
  </svg>
);

const COUNTRIES = [
  { value: 'gb', label: 'United Kingdom' },
  { value: 'kr', label: 'South Korea' },
  { value: 'us', label: 'United States' },
  { value: 'de', label: 'Germany' },
  { value: 'jp', label: 'Japan' },
  { value: 'au', label: 'Australia' }
];

const STEPS = ['Account', 'Verify', 'Profile'];

export default function SignupExample() {
  const [step, setStep] = useState(0);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [agreed, setAgreed] = useState(false);
  const [code, setCode] = useState('');
  const [tried, setTried] = useState(false);

  const emailLooksWrong = tried && !/.+@.+\..+/.test(email);
  const passwordTooShort = tried && password.length < 8;

  function next() {
    if (step === 0) {
      setTried(true);

      if (!/.+@.+\..+/.test(email) || password.length < 8 || !agreed) {
        return;
      }
    }

    setTried(false);
    setStep((current) => Math.min(current + 1, STEPS.length));
  }

  return (
    <div className="@container/page w-full overflow-hidden rounded-(--plass-radius-lg) border [border-color:var(--plass-border)] bg-(--plass-glass)">
      <div className="grid @3xl/page:grid-cols-[1fr_20rem]">
        {/* ---------------------------------------------------------------- */}
        {/* The form                                                          */}
        {/* ---------------------------------------------------------------- */}
        <div className="flex flex-col gap-6 p-6 @xl/page:p-8">
          <PlAppLogo size="sm" name="Halyard" src="/samples/marks/kite.webp" />

          {/* Where you are. A horizontal timeline rather than a progress bar:
              the steps have names, and a bar cannot say them. */}
          <PlTimeline size="sm" orientation="horizontal" active={step}>
            {STEPS.map((name, index) => (
              <PlTimelineItem key={name} title={name} bullet={String(index + 1)} />
            ))}
          </PlTimeline>

          <PlProgressLinear
            size="xs"
            value={(step / STEPS.length) * 100}
            label={`Step ${Math.min(step + 1, STEPS.length)} of ${STEPS.length}`}
          />

          {step === 0 ? (
            <section className="flex flex-col gap-4">
              <div className="flex flex-col gap-1">
                <PlTypography level="h4">Create your account</PlTypography>
                <PlTypography level="body" className="text-(--plass-muted-fg)">
                  Fourteen days free. No card until you decide to stay.
                </PlTypography>
              </div>

              {/* A grid rather than a flex row: a PlButton is `shrink-0`, so two
                  `fullWidth` ones side by side in flex would each ask for the
                  whole row and the second would hang off the end. Two equal
                  columns give them a width to be full of. */}
              <div className="grid gap-2 @lg/page:grid-cols-2">
                <PlButton fullWidth variant="glass" color="secondary" startIcon={<GithubGlyph />}>
                  Continue with GitHub
                </PlButton>
                <PlButton fullWidth variant="glass" color="secondary">
                  Continue with SSO
                </PlButton>
              </div>

              <PlDivider size="xs">or with an email</PlDivider>

              <PlTextField
                fullWidth
                required
                type="email"
                label="Work email"
                startIcon={<MailGlyph />}
                placeholder="you@company.com"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                error={emailLooksWrong ? 'That does not look like an address.' : undefined}
              />

              <PlTextField
                fullWidth
                required
                type="password"
                label="Password"
                startIcon={<LockGlyph />}
                description="Eight characters is the floor, not the target."
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                error={passwordTooShort ? 'Eight characters or more.' : undefined}
              />

              <PlCheckbox
                label={
                  <span>
                    I agree to the{' '}
                    <PlTextLink href="#terms" size="sm">
                      terms
                    </PlTextLink>{' '}
                    and the{' '}
                    <PlTextLink href="#privacy" size="sm">
                      privacy notice
                    </PlTextLink>
                    .
                  </span>
                }
                checked={agreed}
                onCheckedChange={setAgreed}
                error={tried && !agreed ? 'This one is not optional.' : undefined}
              />

              <PlButton onClick={next}>Continue</PlButton>
            </section>
          ) : null}

          {step === 1 ? (
            <section className="flex flex-col gap-4">
              <div className="flex flex-col gap-1">
                <PlTypography level="h4">Check your email</PlTypography>
                <PlTypography level="body" className="text-(--plass-muted-fg)">
                  We sent a six-digit code to{' '}
                  <strong className="text-(--plass-fg)">{email || 'your address'}</strong>.
                </PlTypography>
              </div>

              <PlOtpField
                label="Verification code"
                groupSize={3}
                value={code}
                onValueChange={setCode}
                description={code.length === 6 ? 'Checking…' : 'It expires in ten minutes.'}
              />

              <div className="flex flex-wrap items-center gap-3">
                <PlButton disabled={code.length < 6} onClick={next}>
                  Verify
                </PlButton>
                <PlButton variant="ghost" color="secondary" onClick={() => setCode('')}>
                  Send it again
                </PlButton>
                <PlPopover
                  trigger={
                    <PlButton variant="ghost" color="secondary">
                      Nothing arrived?
                    </PlButton>
                  }
                  title="Nothing arrived?"
                  description="Three things to try"
                >
                  Check the spam folder, then that your address is right, then ask an administrator
                  whether your domain filters us.
                </PlPopover>
              </div>

              <PlButton variant="ghost" color="secondary" onClick={() => setStep(0)}>
                Back
              </PlButton>
            </section>
          ) : null}

          {step === 2 ? (
            <section className="flex flex-col gap-4">
              <div className="flex flex-col gap-1">
                <PlTypography level="h4">Tell us who you are</PlTypography>
                <PlTypography level="body" className="text-(--plass-muted-fg)">
                  All of this can be changed later, and none of it is shared.
                </PlTypography>
              </div>

              <div className="grid gap-4 @lg/page:grid-cols-2">
                <PlTextField fullWidth label="Full name" defaultValue="Ada Lovelace" />
                <PlTextField fullWidth label="Company" defaultValue="Northwind" />
                <PlCombobox fullWidth label="Country" placeholder="Search…" items={COUNTRIES} />
                <PlDatePicker fullWidth label="Start date" placeholder="Pick a day" clearable />
              </div>

              <PlFilePicker
                fullWidth
                size="sm"
                label="Profile picture"
                accept="image/*"
                title="Drop a picture, or click to browse"
                hint="PNG or JPG, up to 2 MB"
              />

              <PlRadioGroup label="What brings you here?" defaultValue="team">
                <PlRadio value="solo" label="I am trying it on my own" />
                <PlRadio value="team" label="I am setting it up for a team" />
                <PlRadio value="looking" label="Someone asked me to evaluate it" />
              </PlRadioGroup>

              <PlSwitch
                className="w-full"
                labelPlacement="start"
                label="Send me the monthly changelog"
                defaultChecked
              />

              <PlButton onClick={next}>Finish</PlButton>
            </section>
          ) : null}

          {step === 3 ? (
            <section className="flex flex-col gap-4">
              <PlAlert
                color="success"
                icon={<PlIcon size="sm" icon={<CheckGlyph />} />}
                title="You are in"
              >
                We are indexing your first repository now. It usually takes about a minute.
              </PlAlert>

              <PlTypography level="body" className="text-(--plass-muted-fg)">
                Nothing else is needed from you today. The first record appears on its own.
              </PlTypography>

              <div className="flex flex-wrap gap-3">
                <PlButton>Open Halyard</PlButton>
                <PlButton
                  variant="ghost"
                  color="secondary"
                  onClick={() => {
                    setStep(0);
                    setCode('');
                    setTried(false);
                  }}
                >
                  Start over
                </PlButton>
              </div>
            </section>
          ) : null}
        </div>

        {/* ---------------------------------------------------------------- */}
        {/* The reassurance column                                            */}
        {/* ---------------------------------------------------------------- */}
        <aside className="hidden flex-col gap-4 border-s bg-(--plass-glass-press) p-6 [border-color:var(--plass-divider)] @3xl/page:flex">
          <PlCard size="sm" title="What you get today" elevation={1}>
            <PlList size="sm" variant="ghost">
              {[
                { line: 'Unlimited runs', note: 'for the whole trial' },
                { line: 'The audit log', note: 'from the first commit' },
                { line: 'Every export', note: 'in the formats you use' }
              ].map((item) => (
                <PlListItem
                  key={item.line}
                  description={item.note}
                  startIcon={<PlIcon size="sm" color="success" icon={<CheckGlyph />} />}
                >
                  {item.line}
                </PlListItem>
              ))}
            </PlList>
          </PlCard>

          <PlBlockquote size="sm" variant="glass" author="Grace Hopper" source="Globex">
            Setting it up took less time than the meeting we had about setting it up.
          </PlBlockquote>

          <div className="mt-auto flex items-center gap-3">
            <PlAvatar size="sm" name="Lucas Adebayo" src="/samples/avatars/lucas-adebayo.webp" />
            <p className="text-xs text-(--plass-muted-fg)">
              Stuck?{' '}
              <PlTextLink href="#help" size="sm">
                An engineer answers
              </PlTextLink>{' '}
              within a working day.
            </p>
          </div>
        </aside>
      </div>
    </div>
  );
}
