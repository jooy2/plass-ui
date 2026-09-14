<script setup>
import { computed, useAttrs } from 'vue';
import { FRAMEWORKS } from '../../data/frameworks';

/**
 * The inline half of `::: fw` — a few words that differ, in the middle of a
 * sentence that does not.
 *
 * `<Fw react="onClick" flutter="onPressed" code />`
 *
 * A container cannot do this: `:::` is a block, and splitting a sentence into
 * two blocks to swap one identifier inside it would leave two paragraphs where
 * there was one. Anything longer than a phrase belongs in the block form.
 *
 * Each framework's text arrives as an attribute named after its id, read off
 * `$attrs` rather than declared, so adding a framework stays one entry in
 * `data/frameworks.ts`. One with nothing given for it renders nothing, which is
 * how a clause only one of them has gets written.
 *
 * An identifier inside a phrase is written the way Markdown writes it, between
 * backticks, and is drawn as `<code>`:
 *
 *     <Fw react="Override it with a class" flutter="`length` overrides it" />
 *
 * The text is split into plain and backticked parts rather than handed to
 * `v-html`, so nothing in an attribute can become markup. A backtick left
 * without a partner is printed as it is. With `code`, the whole variant is one
 * `<code>` and backticks are not read.
 */
defineOptions({ inheritAttrs: false });

defineProps({
  /** Renders each variant as `<code>`, for a prop or an identifier. */
  code: { type: Boolean, default: false }
});

const attrs = useAttrs();

/** A span of backticks with something between them, as Markdown pairs them. */
const CODE_SPAN = /`([^`]+)`/g;

/** The text as a run of plain and code parts, in order. */
function partsOf(text) {
  const parts = [];
  let from = 0;

  for (const match of text.matchAll(CODE_SPAN)) {
    if (match.index > from) {
      parts.push({ code: false, text: text.slice(from, match.index) });
    }

    parts.push({ code: true, text: match[1] });
    from = match.index + match[0].length;
  }

  if (from < text.length) {
    parts.push({ code: false, text: text.slice(from) });
  }

  return parts;
}

const variants = computed(() =>
  FRAMEWORKS.filter((framework) => attrs[framework.id]).map((framework) => {
    const text = String(attrs[framework.id]);

    return { id: framework.id, text, parts: partsOf(text) };
  })
);
</script>

<template>
  <template v-for="variant in variants" :key="variant.id">
    <code v-if="code" class="plass-fw" :data-fw="variant.id">{{ variant.text }}</code>
    <span v-else class="plass-fw" :data-fw="variant.id">
      <template v-for="(part, index) in variant.parts" :key="index">
        <code v-if="part.code">{{ part.text }}</code>
        <template v-else>{{ part.text }}</template>
      </template>
    </span>
  </template>
</template>
