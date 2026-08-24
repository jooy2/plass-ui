import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

const steps = ['Home', 'Projects', 'Aurora', 'Services', 'Ingest', 'Settings'];

export default function BreadcrumbCollapse() {
  return (
    <div className="flex flex-col gap-4">
      <PlBreadcrumb maxItems={4}>
        {steps.map((step, index) => (
          <PlBreadcrumbItem
            key={step}
            href={index === steps.length - 1 ? undefined : '#breadcrumb'}
          >
            {step}
          </PlBreadcrumbItem>
        ))}
      </PlBreadcrumb>

      <PlBreadcrumb maxItems={4} itemsBeforeCollapse={2} itemsAfterCollapse={2} expandable={false}>
        {steps.map((step, index) => (
          <PlBreadcrumbItem
            key={step}
            href={index === steps.length - 1 ? undefined : '#breadcrumb'}
          >
            {step}
          </PlBreadcrumbItem>
        ))}
      </PlBreadcrumb>
    </div>
  );
}
