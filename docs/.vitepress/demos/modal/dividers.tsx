import { PlButton, PlModal, PlModalClose } from 'plass-ui';

export default function ModalDividers() {
  return (
    <PlModal
      dividers
      trigger={<PlButton variant="glass">Read the terms</PlButton>}
      title="Terms of service"
      description="Last updated in March."
      actions={
        <>
          <PlModalClose
            render={
              <PlButton variant="ghost" color="secondary">
                Decline
              </PlButton>
            }
          />
          <PlModalClose render={<PlButton>Accept</PlButton>} />
        </>
      }
    >
      <div className="flex flex-col gap-3">
        {Array.from({ length: 12 }, (_, index) => (
          <p key={index}>
            Clause {index + 1}. The header and the actions stay put while only this part scrolls,
            which is exactly when the hairlines start earning their place.
          </p>
        ))}
      </div>
    </PlModal>
  );
}
