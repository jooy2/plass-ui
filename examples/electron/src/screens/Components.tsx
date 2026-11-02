import { Suspense, lazy, useMemo, useState, type ComponentType } from 'react';
import { PlChip, PlList, PlListItem, PlTextField } from 'plass-ui';

// The same files the documentation mounts, one module per demo.
const modules = import.meta.glob<{ default: ComponentType<Record<string, unknown>> }>(
  '../../../../docs/.vitepress/demos/*/*.tsx'
);

const skipped = new Set(['component-index', 'examples', 'home', 'showcase']);

function demoName(path: string) {
  return path.split('/demos/')[1].replace(/\.tsx$/, '');
}

const demos = new Map(
  Object.entries(modules)
    .filter(([path]) => {
      const name = demoName(path);

      return !skipped.has(name.split('/')[0]) && !/\/(glyphs|items|data)$/.test(name);
    })
    .map(([path, load]) => [demoName(path), lazy(load)])
);

const components = [...new Set([...demos.keys()].map((name) => name.split('/')[0]))].sort();

/** Every name the Components screen can show, for the test that walks them. */
export const demoNames = [...demos.keys()];

/** Every demo, grouped by the component it belongs to. */
export function Components({ initial }: { initial?: string }) {
  const [query, setQuery] = useState('');
  const [demo, setDemo] = useState(initial ?? 'button/hero');
  const component = demo.split('/')[0];
  const Demo = demos.get(demo);
  const found = useMemo(
    () => components.filter((name) => name.includes(query.trim().toLowerCase())),
    [query]
  );

  return (
    <div className="grid h-full min-h-0 grid-cols-[14rem_1fr] gap-4">
      <div className="flex min-h-0 flex-col gap-3">
        <PlTextField
          fullWidth
          aria-label="Search components"
          placeholder={`Search ${components.length} components`}
          value={query}
          onChange={(event) => setQuery(event.target.value)}
        />
        <PlList className="min-h-0 overflow-auto">
          {found.map((name) => (
            <PlListItem
              key={name}
              selected={name === component}
              onClick={() => setDemo(`${name}/hero`)}
            >
              {name}
            </PlListItem>
          ))}
        </PlList>
      </div>

      <div className="flex min-h-0 flex-col gap-3">
        <div className="flex flex-wrap gap-2">
          {[...demos.keys()]
            .filter((name) => name.split('/')[0] === component)
            .map((name) => (
              <PlChip key={name} selected={name === demo} onClick={() => setDemo(name)}>
                {name.split('/')[1]}
              </PlChip>
            ))}
        </div>
        <div className="plass-scope min-h-0 flex-1 overflow-auto p-1" data-testid="demo">
          <Suspense fallback={null}>{Demo ? <Demo key={demo} /> : null}</Suspense>
        </div>
      </div>
    </div>
  );
}
