<script>
/*
 * Module scope, deliberately: a `<script setup>` body runs once per component
 * instance, and a component page carries a dozen <Demo>s. Everything shared by
 * all of them lives here instead.
 */

// Lazy on purpose: the map is built at compile time, but nothing is fetched
// until a demo is actually mounted, and nothing is pulled into the SSR build.
const demos = import.meta.glob('../../demos/**/*.tsx');

let runtime = null;

/** React and its DOM renderer, fetched once and shared by every preview. */
function reactRuntime() {
  runtime ??= Promise.all([import('react'), import('react-dom/client')]);

  return runtime;
}

/*
 * Started here rather than in a preview's `onMounted`, which is what it used to
 * be. Together the two are the largest thing the page downloads, nothing can
 * render until they arrive, and a dynamic import inside a lifecycle hook only
 * begins once hydration is done — so the browser sat idle through hydration and
 * then went to the network. Evaluating this module is the earliest moment the
 * fetch can start, and it costs nothing on a page that turns out to have no
 * previews, since the same promise is what every preview then awaits.
 */
if (!import.meta.env.SSR) {
  reactRuntime();
}

/**
 * How far outside the viewport a preview counts as worth mounting, in px.
 * Wide enough that scrolling reaches a mounted preview rather than an empty box.
 */
const MOUNT_MARGIN = 300;

/**
 * How far outside it a Flutter frame is kept alive, in px.
 *
 * Far wider than `MOUNT_MARGIN`, and a second threshold rather than the same
 * one, because a frame that is torn down the moment it leaves the mount zone
 * would be rebuilt every time the reader scrolled back a screen. A React
 * preview has no equivalent: it is a handful of DOM nodes and it is never
 * unmounted at all, whereas each Flutter frame is a whole engine.
 */
const KEEP_MARGIN = 1200;

/**
 * Whether the Flutter gallery has been built into `public/flutter`.
 *
 * One request for the whole session: without the build the frames would show
 * VitePress's own 404 page, which looks like the preview is broken rather than
 * like a step that has not been run. `version.json` is written by
 * `flutter build web` and is the smallest file in the output.
 */
let flutterProbe = null;

function flutterBuilt(url) {
  flutterProbe ??= fetch(url, { method: 'HEAD' })
    .then((response) => response.ok)
    .catch(() => false);

  return flutterProbe;
}

/** The channel the embedded gallery and this component talk over. */
const CHANNEL = 'plass-demo';
</script>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { useData, withBase } from 'vitepress';
import { basePath, localeOf, t, tf } from '../../data/i18n';
import { framework } from '../../data/framework';
import { FRAMEWORKS } from '../../data/frameworks';
import FrameworkMark from './FrameworkMark.vue';

/**
 * A live preview of a Plass component, in whichever framework the reader picked.
 *
 * **React** is rendered in the page. VitePress compiles Markdown to Vue, so
 * `<PlButton />` cannot be written directly; the bridge is the usual one — Vue
 * owns a plain `<div>`, and React takes it over with `createRoot()` once the
 * page is in the browser.
 *
 * **Flutter** is rendered in an `<iframe>` by the gallery app under
 * `packages/flutter/example`, built into `public/flutter`. It has to be a frame
 * and not a canvas in the page: a Flutter web app owns a whole engine, a
 * document and an event loop. The frame is also why the gallery paints the
 * canvas backdrop itself — `BackdropFilter` can only blur what is drawn behind
 * it *inside the same app*, so a glass button over a transparent frame would
 * have nothing to be in front of and would read as opaque.
 *
 * `src` names a file under `.vitepress/demos` without its extension, so
 * `<Demo src="button/variants" />` renders `demos/button/variants.tsx` — and
 * asks the gallery for the demo registered under the same key. The same path
 * goes into the `<<<` snippet in the Markdown next to it, which is how the code
 * shown under a preview is guaranteed to be the code that ran.
 */
const props = defineProps({
  /** Demo module path, relative to `.vitepress/demos`, without `.tsx`. */
  src: { type: String, required: true },
  /** `center` for a single control that would look lost against a left edge. */
  align: { type: String, default: 'start' },
  /** Drops the frame — for previews that bring their own, like the index grid. */
  plain: { type: Boolean, default: false },
  /**
   * Whether this preview has a Flutter counterpart in the gallery.
   *
   * `false` for the compositions that are about the site rather than about a
   * component — the home hero, the component index — which stay in React
   * whichever framework is selected.
   */
  flutter: { type: Boolean, default: true },
  /**
   * Height the mount point holds, in px or as a CSS length.
   *
   * The box is empty until React is in the browser, so without this the page
   * reflows under the reader the moment a preview arrives. It stays applied
   * after mounting too: a reserve that is dropped once the content is there
   * moves the page a second time, which is the same jump twice.
   */
  minHeight: { type: [Number, String], default: 40 }
});

// `lang` says which language the page is; `localeIndex` says where it lives in
// the URL. They are different questions and only one of them is the default.
const { isDark, lang, localeIndex } = useData();
const locale = localeOf(lang.value);
const base = basePath(localeIndex.value);

const shell = ref(null);
const host = ref(null);
const frame = ref(null);
const open = ref(false);
let root = null;
let observers = [];

/*
 * Which theme this one preview is in, and it is a *deviation* rather than a
 * value: `null` means "whatever the page is", so an untouched preview carries
 * no theme root at all and a reader flipping the site switch takes every
 * preview with them. Only once someone asks for the other one does the canvas
 * become a theme root of its own — which is all it takes, since `styles.css`
 * declares both themes on `[data-theme]` as well as on `:root`.
 */
const override = ref(null);
const pageTheme = computed(() => (isDark.value ? 'dark' : 'light'));
const theme = computed(() => override.value ?? pageTheme.value);

function flip() {
  const next = theme.value === 'dark' ? 'light' : 'dark';

  // Landing back on the page's own theme drops the override instead of pinning
  // it, so the preview rejoins the site switch rather than quietly ignoring it.
  override.value = next === pageTheme.value ? null : next;
}

/* ---------------------------------------------------------------------------
 * Which framework this preview is showing
 * ------------------------------------------------------------------------- */

const embedded = computed(() => props.flutter && framework.value === 'flutter');

const frameworkLabel = computed(
  () => FRAMEWORKS.find((item) => item.id === framework.value)?.label ?? framework.value
);

/**
 * Whether this preview says which framework drew it.
 *
 * On every preview that has both, and on no others. A reader ten screens down
 * the page has long since scrolled past the switch in the sidebar, and "which
 * one am I looking at" is exactly the question a preview should be able to
 * answer about itself. A preview with only one implementation would be
 * answering a question nobody asked.
 */
const marked = computed(() => props.flutter && !props.plain);

/* ---------------------------------------------------------------------------
 * Visibility
 *
 * Two thresholds, watched separately: `near` is close enough to be worth
 * building, `keep` is close enough to be worth holding on to. See the constants
 * above for why a Flutter frame needs the second one.
 * ------------------------------------------------------------------------- */

const near = ref(false);
const keep = ref(false);

function watchMargin(margin, target) {
  if (typeof IntersectionObserver === 'undefined') {
    target.value = true;
    sync();
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      target.value = entries.some((entry) => entry.isIntersecting);
      sync();
    },
    { rootMargin: `${margin}px 0px` }
  );

  // The outer element rather than the React mount point: on Flutter the mount
  // point is `display: none`, and a box with no layout never intersects
  // anything, so every preview on the page would sit at "not visible" forever.
  observer.observe(shell.value);
  observers.push(observer);
}

/* ---------------------------------------------------------------------------
 * React
 * ------------------------------------------------------------------------- */

async function mountReact() {
  if (root) {
    return;
  }

  const key = `../../demos/${props.src}.tsx`;
  const load = demos[key];

  if (!load) {
    console.warn(`[plass-ui docs] no demo at ${key}`);
    return;
  }

  // The demo's own chunk is fetched alongside React rather than after it: it
  // pulls in the components it renders, which is the other half of the payload.
  const [[React, { createRoot }], demo] = await Promise.all([reactRuntime(), load()]);

  // Navigating away during the await leaves nothing to mount into, and a reader
  // who switched to Flutter mid-fetch should not have a React root appear
  // behind the frame.
  if (!host.value || root) {
    return;
  }

  root = createRoot(host.value);
  // Demos are written in English and reused by every locale — they are code
  // samples. The few that carry docs chrome of their own (the component index)
  // take the locale and localise themselves.
  root.render(React.createElement(demo.default, { locale, base }));
}

/* ---------------------------------------------------------------------------
 * Flutter
 * ------------------------------------------------------------------------- */

/** `null` until the probe answers, so nothing is drawn on a guess. */
const built = ref(null);
/** Live once the frame has been near enough; cleared when it drifts far away. */
const frameLive = ref(false);
/** What the gallery reported it needs, in px. */
const frameHeight = ref(null);

const frameSrc = computed(
  () =>
    `${withBase('/flutter/index.html')}?demo=${encodeURIComponent(props.src)}` +
    `&theme=${theme.value}&align=${props.align}`
);

const frameStyle = computed(() => ({
  height: frameHeight.value
    ? `${frameHeight.value}px`
    : typeof props.minHeight === 'number'
      ? `${props.minHeight + 64}px`
      : props.minHeight
}));

function onMessage(event) {
  if (
    event.origin !== window.location.origin ||
    event.source !== frame.value?.contentWindow ||
    event.data?.channel !== CHANNEL
  ) {
    return;
  }

  if (event.data.type === 'size' && typeof event.data.height === 'number') {
    frameHeight.value = Math.ceil(event.data.height);
  }
}

/** Theme changes go over the channel rather than through the `src`: reloading
    the frame would rebuild the engine to change two colours. */
function pushTheme() {
  frame.value?.contentWindow?.postMessage(
    { channel: CHANNEL, type: 'theme', theme: theme.value },
    window.location.origin
  );
}

/* ---------------------------------------------------------------------------
 * Wiring
 * ------------------------------------------------------------------------- */

/**
 * Brings the preview into line with where it is and what it should be.
 *
 * Called rather than watched, from the three places that can change the answer:
 * mounting, an observer crossing a threshold, and the framework switch. A
 * watcher would be the obvious shape and is the wrong one — the first call has
 * to happen inside `onMounted`, after the page has laid out and the box has a
 * position to measure.
 */
async function sync() {
  if (!embedded.value) {
    if (near.value) {
      mountReact();
    }
    return;
  }

  if (near.value) {
    built.value ??= await flutterBuilt(withBase('/flutter/version.json'));
    frameLive.value = true;
  } else if (!keep.value) {
    // Out of sight by a long way: give the engine back.
    frameLive.value = false;
    frameHeight.value = null;
  }
}

// The reader switching framework mid-page: whichever preview they are looking
// at has to change over without waiting to be scrolled past.
watch(embedded, sync);

watch(theme, pushTheme);

onMounted(() => {
  window.addEventListener('message', onMessage);

  /*
   * A component page holds a dozen previews and every one of them used to mount
   * at the same moment, so the preview being read waited its turn behind chunks
   * for previews far below the fold. Only what is on screen mounts now.
   *
   * What is already visible is measured rather than observed: an
   * IntersectionObserver reports its first entry in a later task, and the
   * preview at the top of the page — the one the reader is waiting for — is
   * exactly what that task would delay.
   */
  const { top, bottom } = shell.value.getBoundingClientRect();

  if (top < window.innerHeight + MOUNT_MARGIN && bottom > -MOUNT_MARGIN) {
    near.value = true;
    keep.value = true;
  }

  watchMargin(MOUNT_MARGIN, near);
  watchMargin(KEEP_MARGIN, keep);

  sync();
});

onBeforeUnmount(() => {
  const mounted = root;
  root = null;

  window.removeEventListener('message', onMessage);
  observers.forEach((observer) => observer.disconnect());
  observers = [];

  // React refuses to unmount a root synchronously while it is rendering, and
  // client-side navigation tears the page down from inside Vue's own update.
  if (mounted) {
    setTimeout(() => mounted.unmount(), 0);
  }
});
</script>

<template>
  <div ref="shell" class="plass-demo" :class="{ 'plass-demo--plain': plain }">
    <div
      class="plass-demo-canvas"
      :class="{
        'plass-demo-canvas--marked': marked,
        'plass-demo-canvas--embedded': embedded
      }"
      :data-align="align"
      :data-theme="override"
    >
      <div
        v-if="marked"
        class="plass-demo-badge"
        :title="tf(locale, 'renderedWith', { framework: frameworkLabel })"
      >
        <FrameworkMark :framework="framework" :size="12" />
        <span>{{ frameworkLabel }}</span>
      </div>
      <button
        v-if="!plain"
        type="button"
        class="plass-demo-theme"
        :title="t(locale, theme === 'dark' ? 'viewLight' : 'viewDark')"
        :aria-label="t(locale, theme === 'dark' ? 'viewLight' : 'viewDark')"
        @click="flip"
      >
        <svg
          v-if="theme === 'dark'"
          viewBox="0 0 16 16"
          width="15"
          height="15"
          fill="none"
          stroke="currentColor"
          stroke-width="1.4"
          stroke-linecap="round"
          aria-hidden="true"
        >
          <circle cx="8" cy="8" r="3" />
          <path
            d="M8 1.4v1.3M8 13.3v1.3M1.4 8h1.3M13.3 8h1.3M3.4 3.4l.9.9M11.7 11.7l.9.9M12.6 3.4l-.9.9M4.3 11.7l-.9.9"
          />
        </svg>
        <svg
          v-else
          viewBox="0 0 16 16"
          width="15"
          height="15"
          fill="none"
          stroke="currentColor"
          stroke-width="1.4"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M13.4 10.1A5.7 5.7 0 0 1 5.9 2.6a5.7 5.7 0 1 0 7.5 7.5Z" />
        </svg>
      </button>
      <div
        v-show="!embedded"
        ref="host"
        class="plass-scope plass-demo-mount"
        :style="{ minHeight: typeof minHeight === 'number' ? `${minHeight}px` : minHeight }"
      />
      <template v-if="embedded">
        <p v-if="built === false" class="plass-fw-missing plass-demo-unbuilt">
          {{ tf(locale, 'demoMissing', { framework: frameworkLabel }) }}
        </p>
        <iframe
          v-else-if="frameLive"
          ref="frame"
          class="plass-demo-frame"
          :src="frameSrc"
          :style="frameStyle"
          :title="tf(locale, 'demoTitle', { framework: frameworkLabel })"
          @load="pushTheme"
        />
        <div v-else class="plass-demo-frame" :style="frameStyle" />
      </template>
    </div>
    <div v-if="$slots.default" class="plass-demo-source">
      <button
        type="button"
        class="plass-demo-toggle"
        :aria-expanded="open ? 'true' : 'false'"
        @click="open = !open"
      >
        <span class="plass-demo-toggle-icon" :class="{ 'is-open': open }" aria-hidden="true"
          >›</span
        >
        {{ open ? t(locale, 'hideCode') : t(locale, 'showCode') }}
      </button>
      <div v-show="open" class="plass-demo-code">
        <slot />
      </div>
    </div>
  </div>
</template>
