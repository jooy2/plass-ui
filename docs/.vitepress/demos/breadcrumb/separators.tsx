import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

export default function BreadcrumbSeparators() {
  return (
    <div className="flex flex-col gap-4">
      {(['chevron', 'arrow', 'slash', 'dot'] as const).map((separator) => (
        <PlBreadcrumb key={separator} separator={separator}>
          <PlBreadcrumbItem href="#breadcrumb">Home</PlBreadcrumbItem>
          <PlBreadcrumbItem href="#breadcrumb">Docs</PlBreadcrumbItem>
          <PlBreadcrumbItem>{separator}</PlBreadcrumbItem>
        </PlBreadcrumb>
      ))}

      <PlBreadcrumb separator={<span className="text-(--plass-muted-fg)">→</span>}>
        <PlBreadcrumbItem href="#breadcrumb">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem href="#breadcrumb">Docs</PlBreadcrumbItem>
        <PlBreadcrumbItem>a node of your own</PlBreadcrumbItem>
      </PlBreadcrumb>
    </div>
  );
}
