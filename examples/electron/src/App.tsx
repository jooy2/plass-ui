import { Suspense, lazy, useEffect, useState, type ReactNode } from 'react';
import {
  PlConfirmProvider,
  PlList,
  PlListItem,
  PlToastProvider,
  PlTooltipProvider,
  PlassProvider,
  usePlColorScheme
} from 'plass-ui';
import { Components } from './screens/Components';
import { Desktop } from './screens/Desktop';
import { Inbox } from './screens/Inbox';
import { Overlays } from './screens/Overlays';
import { Settings } from './screens/Settings';

// The documentation's whole-screen examples, unchanged.
const Dashboard = lazy(() => import('../../../docs/.vitepress/demos/examples/dashboard'));
const Landing = lazy(() => import('../../../docs/.vitepress/demos/examples/landing'));
const Signup = lazy(() => import('../../../docs/.vitepress/demos/examples/signup'));
const Showcase = lazy(() => import('../../../docs/.vitepress/demos/showcase/app'));

export interface Preferences {
  scheme: 'system' | 'light' | 'dark';
  rtl: boolean;
  compact: boolean;
  locale: string;
}

const screens = {
  dashboard: 'Dashboard',
  inbox: 'Inbox',
  overlays: 'Overlays',
  desktop: 'Desktop',
  showcase: 'Showcase',
  signup: 'Sign-up',
  landing: 'Landing',
  components: 'Components',
  settings: 'Settings'
} as const;

type Screen = keyof typeof screens;

function route() {
  const [screen, ...rest] = location.hash.replace(/^#\/?/, '').split('/');

  return {
    screen: (screen in screens ? screen : 'dashboard') as Screen,
    demo: rest.length > 0 ? rest.join('/') : undefined
  };
}

export function App() {
  const [{ screen, demo }, setRoute] = useState(route);
  const [preferences, setPreferences] = useState<Preferences>({
    scheme: 'system',
    rtl: false,
    compact: false,
    locale: 'en-US'
  });
  const { setScheme } = usePlColorScheme();

  useEffect(() => {
    const update = () => setRoute(route());

    window.addEventListener('hashchange', update);

    return () => window.removeEventListener('hashchange', update);
  }, []);

  useEffect(() => {
    setScheme(preferences.scheme);
    window.desktop?.setTheme(preferences.scheme);
  }, [preferences.scheme, setScheme]);

  useEffect(() => {
    document.documentElement.dir = preferences.rtl ? 'rtl' : 'ltr';
  }, [preferences.rtl]);

  const content: Record<Screen, ReactNode> = {
    dashboard: <Dashboard />,
    inbox: <Inbox />,
    overlays: <Overlays />,
    desktop: <Desktop />,
    showcase: <Showcase />,
    signup: <Signup />,
    landing: <Landing />,
    components: <Components initial={demo} />,
    settings: (
      <Settings
        preferences={preferences}
        onChange={(next) => setPreferences((current) => ({ ...current, ...next }))}
      />
    )
  };

  return (
    <PlassProvider
      density={preferences.compact ? 'compact' : undefined}
      locale={preferences.locale}
    >
      <PlTooltipProvider>
        <PlToastProvider>
          <PlConfirmProvider>
            <div className="flex h-full flex-col">
              <div className="title-bar h-10 shrink-0" />
              <div className="flex min-h-0 flex-1 gap-4 px-4 pb-4">
                <nav aria-label="Main" className="w-48 shrink-0">
                  <PlList>
                    {(Object.keys(screens) as Screen[]).map((one) => (
                      <PlListItem
                        key={one}
                        selected={one === screen}
                        onClick={() => {
                          location.hash = `#/${one}`;
                        }}
                      >
                        {screens[one]}
                      </PlListItem>
                    ))}
                  </PlList>
                </nav>
                <main className="min-h-0 min-w-0 flex-1 overflow-auto">
                  <Suspense fallback={null}>{content[screen]}</Suspense>
                </main>
              </div>
            </div>
          </PlConfirmProvider>
        </PlToastProvider>
      </PlTooltipProvider>
    </PlassProvider>
  );
}
