import { PlButton } from 'plass-ui';

export default function ButtonRender() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton render={<a href="https://plass.cdget.com" />}>Documentation</PlButton>
      <PlButton variant="glass" render={<a href="https://plass.cdget.com/components/" />}>
        All components
      </PlButton>
    </div>
  );
}
