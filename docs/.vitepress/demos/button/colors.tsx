import { Button } from 'plass-ui';

export default function ButtonColors() {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center gap-3">
        <Button color="primary">Primary</Button>
        <Button color="secondary">Secondary</Button>
        <Button color="success">Success</Button>
        <Button color="warning">Warning</Button>
        <Button color="danger">Danger</Button>
        <Button color="info">Info</Button>
      </div>
      <div className="flex flex-wrap items-center gap-3">
        <Button variant="glass" color="primary">
          Primary
        </Button>
        <Button variant="glass" color="secondary">
          Secondary
        </Button>
        <Button variant="glass" color="success">
          Success
        </Button>
        <Button variant="glass" color="warning">
          Warning
        </Button>
        <Button variant="glass" color="danger">
          Danger
        </Button>
        <Button variant="glass" color="info">
          Info
        </Button>
      </div>
    </div>
  );
}
