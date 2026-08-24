import { PlBreadcrumb, PlBreadcrumbItem } from 'plass-ui';

function HomeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5">
      <path d="M2.5 7 8 2.5 13.5 7v6a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5Z" strokeLinejoin="round" />
    </svg>
  );
}

export default function BreadcrumbHero() {
  return (
    <PlBreadcrumb>
      <PlBreadcrumbItem href="#breadcrumb" startIcon={<HomeIcon />}>
        Home
      </PlBreadcrumbItem>
      <PlBreadcrumbItem href="#breadcrumb">Settings</PlBreadcrumbItem>
      <PlBreadcrumbItem href="#breadcrumb">Workspace</PlBreadcrumbItem>
      <PlBreadcrumbItem>Billing</PlBreadcrumbItem>
    </PlBreadcrumb>
  );
}
