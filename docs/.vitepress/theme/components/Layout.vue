<script setup>
import DefaultTheme from 'vitepress/theme';
import { withBase } from 'vitepress';
import Demo from './Demo.vue';

/**
 * The default layout with two things added to the home page: the mark above the
 * hero's title, and a hero "image" that is a live composition of the library's
 * own components rather than a picture.
 *
 * The image slot only renders when the frontmatter declares `hero.image`, so
 * the home pages keep an `image` entry even though nothing of it is drawn.
 *
 * `width` and `height` are on the tag so the hero does not jump once the mark
 * arrives. Both slots exist only on `layout: home`.
 */
const { Layout } = DefaultTheme;
</script>

<template>
  <Layout>
    <template #home-hero-info-before>
      <img
        class="plass-home-logo"
        :src="withBase('/logo.svg')"
        alt="Plass"
        width="96"
        height="96"
        fetchpriority="high"
      />
    </template>
    <template #home-hero-image>
      <Demo class="plass-home-hero" src="home/hero" plain :min-height="260" />
    </template>
  </Layout>
</template>
