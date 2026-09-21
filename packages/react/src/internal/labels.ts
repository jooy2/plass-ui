'use client';

/**
 * Every word this library says on its own behalf.
 *
 * There are two kinds of string in a component library and only one of them
 * belongs here. A `PlButton`'s children, a `PlAlert`'s message and a
 * `PlIconButton`'s required `label` are the **caller's** words: they arrive in
 * whatever language the application is written in, and the library never sees
 * them. What is in this file is the other kind — the words a component has to
 * produce itself because nobody handed it any: "Close" on a modal's ×,
 * "Previous page" on a pagination arrow, "Skip to content" on a layout's first
 * link.
 *
 * They used to be English literals in thirty component files, which made a
 * Korean application a search for thirty props. One object is what makes a
 * translation a **file** rather than a hunt, and `src/locales/` is where the
 * finished ones live.
 *
 * **A key is a meaning, not a component.** "Close" is one word whether it is on
 * a modal, a drawer, a popover or a toast, so it is one key — a translator who
 * had to answer it four times would be transcribing rather than translating.
 * Where two components genuinely say different things they get different keys:
 * a carousel's `carouselNext` is "Next slide" and a scroll zone's `next` is
 * "Next", because one names a thing and the other names a direction.
 *
 * The dates are deliberately absent. `Intl` already knows what July is called
 * in more languages than this file ever will, and a month name written down
 * here would be a second answer to a question the platform has already
 * answered.
 */

import * as React from 'react';
import { useDefaults } from './defaults.js';

export interface PlassLabels {
  /* -------------------------------------------------------------------------
   * The words more than one component says
   * ---------------------------------------------------------------------- */

  /** The × on a modal, a drawer, a popover, a toast. */
  close: string;
  /** The way out of a question that has two answers. */
  cancel: string;
  /** The other one. */
  confirm: string;
  /** The one button on a message that only needs to have been read. */
  acknowledge: string;
  /** Empties a field, a picker, a search. */
  clear: string;
  /** Finishes with a picker, or with a tour. */
  done: string;
  /** Leaves a sequence before the end of it. */
  skip: string;
  /** Names a search field the caller did not name. */
  search: string;
  /** Ticks everything in a list at once. */
  selectAll: string;
  /** Ticks one row of a table, whose own name is the row's contents. */
  selectRow: string;
  /** Takes one thing out of a set. */
  remove: string;
  /** Sends a message away without answering it. */
  dismiss: string;
  /** Opens a list a field is attached to. */
  open: string;
  /** A direction, on the two components that only move one step. */
  previous: string;
  next: string;
  /** Uncovers and re-covers hidden content. */
  reveal: string;
  hide: string;
  /** A number field's two steppers. */
  increase: string;
  decrease: string;
  /** Opens a picture over the page. */
  preview: string;
  /** What a list says when it has nothing in it. */
  empty: string;
  /** Marks a step, or anything else, that may be left out. */
  optional: string;

  /* -------------------------------------------------------------------------
   * The words one component says
   * ---------------------------------------------------------------------- */

  /** The trail's landmark, and the button that opens the steps it folded away. */
  breadcrumb: string;
  breadcrumbExpand: string;
  /** The reel's landmark and its two steppers, which move by a slide. */
  carousel: string;
  carouselPrevious: string;
  carouselNext: string;
  /** What a slide is, said after its name: one slide's `aria-roledescription`.
   * The reel's own is `carousel`. */
  slide: string;
  /** The wall of pictures' own landmark. */
  gallery: string;
  /** What a drawing of numbers is called when the caller has not named it. */
  chart: string;
  /**
   * The category a chart folds its smallest ones into. Not a name for any of
   * them — it is what is left once the ones worth drawing have been drawn.
   */
  chartOther: string;
  /** The legend's own "and this many more", on a chart with more series than it shows. */
  chartMore: (count: number) => string;
  /** And the way back, once they are all showing. */
  chartFewer: string;
  minimize: string;
  maximize: string;
  restore: string;
  resizeWindow: string;
  /** The palette's landmark and the placeholder in its field. */
  commandPalette: string;
  commandPalettePlaceholder: string;
  /** What a sheet over the whole page is called when it has no name. */
  overlay: string;
  /** The region the toasts are announced in. */
  notifications: string;
  /** The pager's landmark and its four steppers, which move by a page. */
  pagination: string;
  paginationPrevious: string;
  paginationNext: string;
  paginationFirst: string;
  paginationLast: string;
  /** The stars' group. */
  rating: string;
  /** The panel's landmark, the buttons that open and shut it, and the handle
   * that sizes it. */
  sidebar: string;
  sidebarOpen: string;
  sidebarClose: string;
  sidebarResize: string;
  /** The first link on a page, which jumps past the furniture. */
  skipToContent: string;
  /** The button that goes back up a long page. */
  backToTop: string;
  /** The table of contents' own landmark. */
  onThisPage: string;
  /** What a chat bubble says while somebody is still writing. */
  typing: string;
  /** What a chat bubble's mark says about the message it is on. */
  messageSending: string;
  messageSent: string;
  messageDelivered: string;
  messageRead: string;
  messageFailed: string;
  /** What covers a spoiler until it is revealed. */
  spoilerWarning: string;
  /** What a file picker's drop zone says when the caller has not said. */
  filePickerTitle: string;
  /** Read out after a link that leaves the page, and never drawn. */
  newTab: string;
  /** The two columns of a transfer, and the buttons between them. */
  transferAvailable: string;
  transferSelected: string;
  transferToSelected: string;
  transferToAvailable: string;
  /** The code block's bar: the button, what it says once it has worked, and
   * what it says when the clipboard refused. */
  copy: string;
  copied: string;
  copyFailed: string;
  /** The toggle that drops a block's colouring. */
  raw: string;
  /** What a block of code is called when it has neither a title nor a language. */
  code: string;

  /* -------------------------------------------------------------------------
   * The pickers
   *
   * These were the first set to be collected, back when `labels` meant only a
   * picker's words. They are in the same object now and mean the same thing.
   * ---------------------------------------------------------------------- */

  /** The calendar's steppers, in day view. */
  previousMonth: string;
  nextMonth: string;
  /** The same steppers in month view, where they move by a year. */
  previousYear: string;
  nextYear: string;
  /** And in year view, where they move by a page of twelve. */
  previousYears: string;
  nextYears: string;
  /** The two header buttons that open the month grid and the year grid. */
  chooseMonth: string;
  chooseYear: string;
  /** The footer's actions. */
  today: string;
  /** The same shortcut on a picker that only asks for a month or a year. */
  thisMonth: string;
  thisYear: string;
  now: string;
  /** The clock's columns. */
  hour: string;
  minute: string;
  second: string;
  meridiem: string;
  /** Which end of a range the calendar is currently asking for. */
  start: string;
  end: string;

  /* -------------------------------------------------------------------------
   * The words with a value in them
   *
   * Functions rather than strings, because a sentence with a number in it is
   * not a word with the number stuck on. "Page 3 of 12" is `12페이지 중
   * 3페이지` in Korean and `第3页，共12页` in Chinese: the order moves, and a
   * template the component filled in would have fixed it in English's. Each
   * one is handed its values and answers the whole sentence.
   * ---------------------------------------------------------------------- */

  /** A page button's name. */
  paginationPage: (page: number) => string;
  /** What the pager's live region says once the page has changed. */
  paginationStatus: (page: number, count: number) => string;
  /** What one star is called, and a read-only row with a score. The score can
   * be a fraction, so a pack writes it the way its language writes a number:
   * `2.5` in English, `2,5` in German. */
  ratingValue: (value: number, count: number) => string;
  /** And a read-only row with none. */
  ratingNone: string;
  /** One slide's name, which is also its dot's. */
  carouselSlide: (index: number, count: number) => string;
  /** Where a picture sits in a gallery: said after a tile's own words, and
   * drawn as the viewer's counter. */
  galleryItem: (index: number, total: number) => string;
  /** A remove button named after what it takes away: a file, a chip. */
  removeItem: (name: string) => string;
  /** The row that offers what was typed as a value of its own. */
  addCustom: (query: string) => string;
  /** One slot of a code field, named by its place in the row. */
  otpSlot: (index: number, count: number) => string;
  /** What a transfer says once rows have moved, given how many and the list. */
  transferMoved: (count: number, list: string) => string;
  /**
   * Why a file picker turned files away, one line per reason and given how many
   * were turned away for it.
   *
   * Grouped by reason rather than named one file at a time, because the batch
   * that goes wrong is usually the big one — a folder dropped on a picker with
   * a `maxFiles` of five is ninety-five lines saying the same thing. What the
   * limit itself *is* belongs in `hint`, which is where a picker already says
   * what it accepts, so these do not repeat it.
   */
  filesRejectedType: (count: number) => string;
  filesRejectedSize: (count: number) => string;
  filesRejectedCount: (count: number) => string;
}

/**
 * English, and the reason the library needs no setup to read.
 *
 * Every locale in `src/locales/` is this object with the values replaced, which
 * is what makes a missing key a type error rather than a word that quietly
 * stays English.
 */
export const defaultLabels: PlassLabels = {
  close: 'Close',
  cancel: 'Cancel',
  confirm: 'Confirm',
  acknowledge: 'OK',
  clear: 'Clear',
  done: 'Done',
  skip: 'Skip',
  search: 'Search',
  selectAll: 'Select all',
  selectRow: 'Select row',
  remove: 'Remove',
  dismiss: 'Dismiss',
  open: 'Open',
  previous: 'Previous',
  next: 'Next',
  reveal: 'Reveal',
  hide: 'Hide',
  increase: 'Increase',
  decrease: 'Decrease',
  preview: 'Preview',
  empty: 'Nothing here',
  optional: 'Optional',

  breadcrumb: 'Breadcrumb',
  breadcrumbExpand: 'Show the hidden steps',
  carousel: 'Carousel',
  carouselPrevious: 'Previous slide',
  carouselNext: 'Next slide',
  slide: 'slide',
  commandPalette: 'Command palette',
  commandPalettePlaceholder: 'Search commands',
  gallery: 'Gallery',
  chart: 'Chart',
  chartOther: 'Other',
  chartMore: (count) => `${count} more`,
  chartFewer: 'Show fewer',
  minimize: 'Minimize',
  maximize: 'Maximize',
  restore: 'Restore',
  resizeWindow: 'Resize window',
  overlay: 'Overlay',
  notifications: 'Notifications',
  pagination: 'Pagination',
  paginationPrevious: 'Previous page',
  paginationNext: 'Next page',
  paginationFirst: 'First page',
  paginationLast: 'Last page',
  rating: 'Rating',
  sidebar: 'Sidebar',
  sidebarOpen: 'Open sidebar',
  sidebarClose: 'Close sidebar',
  sidebarResize: 'Resize sidebar',
  skipToContent: 'Skip to content',
  backToTop: 'Back to top',
  onThisPage: 'On this page',
  typing: 'Typing…',
  messageSending: 'Sending',
  messageSent: 'Sent',
  messageDelivered: 'Delivered',
  messageRead: 'Read',
  messageFailed: 'Not delivered',
  spoilerWarning: 'This may contain spoilers',
  filePickerTitle: 'Drop files here, or click to browse',
  newTab: '(opens in a new tab)',
  transferAvailable: 'Available',
  transferSelected: 'Selected',
  transferToSelected: 'Move to selected',
  transferToAvailable: 'Move to available',
  copy: 'Copy',
  copied: 'Copied',
  copyFailed: 'Could not copy',
  raw: 'Raw',
  code: 'Code',

  previousMonth: 'Previous month',
  nextMonth: 'Next month',
  previousYear: 'Previous year',
  nextYear: 'Next year',
  previousYears: 'Previous years',
  nextYears: 'Next years',
  chooseMonth: 'Choose a month',
  chooseYear: 'Choose a year',
  today: 'Today',
  thisMonth: 'This month',
  thisYear: 'This year',
  now: 'Now',
  hour: 'Hour',
  minute: 'Minute',
  second: 'Second',
  meridiem: 'AM/PM',
  start: 'Start',
  end: 'End',

  paginationPage: (page) => `Page ${page}`,
  paginationStatus: (page, count) => `Page ${page} of ${count}`,
  ratingValue: (value, count) => `${value.toLocaleString('en')} out of ${count}`,
  ratingNone: 'No rating',
  carouselSlide: (index, count) => `Slide ${index} of ${count}`,
  galleryItem: (index, total) => `${index} of ${total}`,
  removeItem: (name) => `Remove ${name}`,
  addCustom: (query) => `Add “${query}”`,
  otpSlot: (index, count) => `Character ${index} of ${count}`,
  transferMoved: (count, list) => `${count} ${count === 1 ? 'item' : 'items'} moved to ${list}`,
  filesRejectedType: (count) =>
    `${count} ${count === 1 ? 'file is' : 'files are'} not an accepted type`,
  filesRejectedSize: (count) => `${count} ${count === 1 ? 'file is' : 'files are'} too large`,
  filesRejectedCount: (count) => `${count} ${count === 1 ? 'file' : 'files'} did not fit`
};

/**
 * The words in scope, resolved once per render.
 *
 * Two layers: the English above, and whatever a `PlassProvider` set. A
 * component's own `*Label` prop is the third and narrowest, and it is applied
 * at the call site rather than here — which is what lets an application
 * translate the vocabulary once and one button still say something else.
 */
export function useLabels(): PlassLabels {
  const { labels } = useDefaults();

  return React.useMemo(() => (labels ? { ...defaultLabels, ...labels } : defaultLabels), [labels]);
}
