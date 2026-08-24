import { PlButton } from 'plass-ui';

export default function ButtonColors() {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center gap-3">
        <PlButton color="primary">Primary</PlButton>
        <PlButton color="secondary">Secondary</PlButton>
        <PlButton color="success">Success</PlButton>
        <PlButton color="warning">Warning</PlButton>
        <PlButton color="danger">Danger</PlButton>
        <PlButton color="info">Info</PlButton>
      </div>
      <div className="flex flex-wrap items-center gap-3">
        <PlButton variant="glass" color="primary">
          Primary
        </PlButton>
        <PlButton variant="glass" color="secondary">
          Secondary
        </PlButton>
        <PlButton variant="glass" color="success">
          Success
        </PlButton>
        <PlButton variant="glass" color="warning">
          Warning
        </PlButton>
        <PlButton variant="glass" color="danger">
          Danger
        </PlButton>
        <PlButton variant="glass" color="info">
          Info
        </PlButton>
      </div>
    </div>
  );
}
