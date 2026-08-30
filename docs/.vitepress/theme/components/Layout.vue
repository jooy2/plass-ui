<script setup>
import DefaultTheme from 'vitepress/theme';
import { onContentUpdated, withBase } from 'vitepress';
import { nextTick, watch } from 'vue';
import Demo from './Demo.vue';
import FrameworkSelect from './FrameworkSelect.vue';
import { framework } from '../../data/framework';

/**
 * The default layout with three additions: the framework switch above the
 * sidebar menu, and — on the home page — the mark above the hero's title and a
 * hero "image" that is a live composition of the library's own components
 * rather than a picture.
 *
 * The image slot only renders when the frontmatter declares `hero.image`, so
 * the home pages keep an `image` entry even though nothing of it is drawn.
 *
 * `width` and `height` are on the tag so the hero does not jump once the mark
 * arrives. Both slots exist only on `layout: home`.
 */
const { Layout } = DefaultTheme;

/* ---------------------------------------------------------------------------
 * The outline, filtered to the selected framework
 *
 * A heading inside a `::: fw` block is hidden with the block it belongs to, but
 * VitePress builds "On this page" from the Markdown rather than from the DOM —
 * so without this a reader on Flutter is offered a link to `render`, which is
 * React-only, and clicking it scrolls to nothing.
 *
 * Done here rather than by teaching the outline about frameworks because the
 * outline is the default theme's, and this is a handful of lines against a
 * fork of it. The anchors are the join: an outline link's `href` is the id of
 * the heading it points at, and the heading knows which block it is in.
 * ------------------------------------------------------------------------- */

function syncOutline() {
  const doc = document.querySelector('.vp-doc');

  if (!doc) {
    return;
  }

  for (const link of document.querySelectorAll('.outline-link')) {
    const id = decodeURIComponent(link.getAttribute('href')?.slice(1) ?? '');
    const heading = id ? doc.querySelector(`[id="${CSS.escape(id)}"]`) : null;
    const block = heading?.closest('.plass-fw');
    const hidden = Boolean(block) && !block.dataset.fw.split(' ').includes(framework.value);

    (link.closest('li') ?? link).classList.toggle('plass-fw-hidden', hidden);
  }
}

// `onContentUpdated` is the hook the outline itself is built on, so it fires on
// the first render and on every navigation — and a `nextTick` puts this after
// the outline has been rebuilt rather than in the middle of it.
onContentUpdated(() => nextTick(syncOutline));

// And again when the reader switches framework, which changes which half of the
// page exists without changing the page.
watch(framework, () => nextTick(syncOutline));
</script>

<template>
  <Layout>
    <template #sidebar-nav-before>
      <FrameworkSelect />
    </template>
    <template #home-hero-info-before>
      <img
        class="plass-home-logo"
        :src="withBase('/256x256.png')"
        alt="Plass"
        width="96"
        height="96"
        fetchpriority="high"
      />
    </template>
    <template #home-hero-image>
      <Demo class="plass-home-hero" src="home/hero" plain :flutter="false" :min-height="260" />
    </template>
  </Layout>
</template>
