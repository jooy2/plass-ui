import { PlCollapsible } from 'plass-ui';

export default function CollapsibleHiddenUntilFound() {
  return (
    <PlCollapsible hiddenUntilFound className="w-full max-w-md" title="Shipping abroad">
      Orders leave the warehouse within two working days. The country an order arrives in may charge
      customs duties, and they are paid on delivery.
    </PlCollapsible>
  );
}
