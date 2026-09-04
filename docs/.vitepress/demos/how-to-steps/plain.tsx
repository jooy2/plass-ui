import { PlHowToStep, PlHowToSteps } from 'plass-ui';

export default function HowToStepsPlain() {
  return (
    <PlHowToSteps className="w-full max-w-md" numbered={false} connector="none" density="compact">
      <PlHowToStep title="Check the licence">Before anything is added.</PlHowToStep>
      <PlHowToStep title="Check the size">Before anything is shipped.</PlHowToStep>
      <PlHowToStep title="Check the contrast">Before anything is drawn.</PlHowToStep>
    </PlHowToSteps>
  );
}
