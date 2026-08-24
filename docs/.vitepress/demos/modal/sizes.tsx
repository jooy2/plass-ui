import { PlButton, PlModal, PlModalClose } from 'plass-ui';

export default function ModalSizes() {
  return (
    <div className="flex flex-wrap gap-2">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlModal
          key={size}
          size={size}
          trigger={<PlButton variant="glass">{size}</PlButton>}
          title={`size="${size}"`}
          description="The width and the type scale move together."
          actions={<PlModalClose render={<PlButton size="sm">Close</PlButton>} />}
        >
          How long a line of text is comfortable inside the sheet is the question this ladder
          answers, which is why its steps are further apart than the control heights.
        </PlModal>
      ))}
    </div>
  );
}
