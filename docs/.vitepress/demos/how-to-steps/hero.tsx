import { PlHowToStep, PlHowToSteps } from 'plass-ui';

export default function HowToStepsHero() {
  return (
    <PlHowToSteps className="w-full max-w-md" active={1}>
      <PlHowToStep title="Add the package">
        <code>npm install plass-ui</code> — there is nothing else to install.
      </PlHowToStep>
      <PlHowToStep title="Import the stylesheet">
        One line at the top of your CSS entry point.
      </PlHowToStep>
      <PlHowToStep title="Drop a component in">
        A <code>PlButton</code> looks like a <code>PlButton</code> with no setup at all.
      </PlHowToStep>
    </PlHowToSteps>
  );
}
