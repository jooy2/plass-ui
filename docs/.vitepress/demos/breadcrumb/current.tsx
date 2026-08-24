import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

export default function BreadcrumbCurrent() {
  return (
    <div className="flex flex-col gap-4">
      <PlBreadcrumb>
        <PlBreadcrumbItem href="#breadcrumb">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem href="#breadcrumb">Docs</PlBreadcrumbItem>
        <PlBreadcrumbItem>The last step is the current one</PlBreadcrumbItem>
      </PlBreadcrumb>

      <PlBreadcrumb>
        <PlBreadcrumbItem href="#breadcrumb">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem current href="#breadcrumb">
          Claimed here instead
        </PlBreadcrumbItem>
        <PlBreadcrumbItem href="#breadcrumb">Still a link</PlBreadcrumbItem>
      </PlBreadcrumb>

      <PlBreadcrumb>
        <PlBreadcrumbItem href="#breadcrumb">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem disabled href="#breadcrumb">
          Unavailable
        </PlBreadcrumbItem>
        <PlBreadcrumbItem>Here</PlBreadcrumbItem>
      </PlBreadcrumb>
    </div>
  );
}
