import { Button } from 'plass-ui';

export default function ButtonRender() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <Button render={<a href="https://plass-ui.cdget.com" />}>Documentation</Button>
      <Button variant="glass" render={<a href="https://plass-ui.cdget.com/components/" />}>
        All components
      </Button>
    </div>
  );
}
