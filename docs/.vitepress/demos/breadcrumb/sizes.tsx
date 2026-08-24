import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

export default function BreadcrumbSizes() {
  return (
    <div className="flex flex-col gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlBreadcrumb key={size} size={size}>
          <PlBreadcrumbItem href="#breadcrumb">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem href="#breadcrumb">Docs</PlBreadcrumbItem>
          <PlBreadcrumbItem>{size}</PlBreadcrumbItem>
        </PlBreadcrumb>
      ))}
    </div>
  );
}
