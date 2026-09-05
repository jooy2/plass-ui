import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCodeBlock } from 'plass-ui';

const code = `const answer = 42;\nconsole.log(answer);`;

const lines = () =>
  Array.from(document.querySelectorAll<HTMLElement>('.plass-code-line')).map(
    (node) => node.textContent
  );

describe('PlCodeBlock', () => {
  describe('rendering', () => {
    it('draws the code one line at a time', async () => {
      await render(<PlCodeBlock code={code} highlight={false} />);

      expect(lines()).toEqual(['const answer = 42;', 'console.log(answer);']);
    });

    it('trims the trailing blank a template literal leaves behind', async () => {
      await render(<PlCodeBlock code={'a\nb\n\n  '} highlight={false} />);

      expect(lines()).toEqual(['a', 'b']);
    });

    it('normalises the carriage returns a file written on Windows carries', async () => {
      await render(<PlCodeBlock code={'a\r\nb'} highlight={false} />);

      expect(lines()).toEqual(['a', 'b']);
    });

    it('keeps a blank line in the middle', async () => {
      await render(<PlCodeBlock code={'a\n\nb'} highlight={false} />);

      expect(lines()).toEqual(['a', '', 'b']);
    });

    it('is a focusable region named after the language', async () => {
      const screen = await render(<PlCodeBlock code={code} language="ts" highlight={false} />);

      await expect.element(screen.getByRole('region', { name: 'typescript' })).toBeInTheDocument();
    });

    it('is named after the title when there is one', async () => {
      const screen = await render(
        <PlCodeBlock code={code} title="src/index.ts" highlight={false} />
      );

      await expect
        .element(screen.getByRole('region', { name: 'src/index.ts' }))
        .toBeInTheDocument();
    });

    it('falls back to the word for code', async () => {
      const screen = await render(<PlCodeBlock code={code} highlight={false} />);

      await expect.element(screen.getByRole('region', { name: 'Code' })).toBeInTheDocument();
    });

    it('carries the theme it was given', async () => {
      await render(<PlCodeBlock code={code} theme="dracula" highlight={false} />);

      expect(document.querySelector('.plass-code')).toHaveAttribute('data-code-theme', 'dracula');
    });

    it('takes a theme nobody registered', async () => {
      await render(<PlCodeBlock code={code} theme="ours" highlight={false} />);

      expect(document.querySelector('.plass-code')).toHaveAttribute('data-code-theme', 'ours');
    });

    it('reflects a changed code on re-render', async () => {
      const screen = await render(<PlCodeBlock code="first" highlight={false} />);

      expect(lines()).toEqual(['first']);

      await screen.rerender(<PlCodeBlock code="second" highlight={false} />);

      expect(lines()).toEqual(['second']);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlCodeBlock code={code} className="my-own-class" highlight={false} />);

      expect(document.querySelector('.plass-code')).toHaveClass('my-own-class');
    });
  });

  describe('the bar', () => {
    it('names the language', async () => {
      const screen = await render(<PlCodeBlock code={code} language="tsx" highlight={false} />);

      await expect.element(screen.getByText('typescript')).toBeInTheDocument();
    });

    it('draws a title beside it', async () => {
      const screen = await render(
        <PlCodeBlock code={code} language="ts" title="src/index.ts" highlight={false} />
      );

      await expect.element(screen.getByText('src/index.ts')).toBeInTheDocument();
      await expect.element(screen.getByText('typescript')).toBeInTheDocument();
    });

    it('drops the whole bar when it is turned off', async () => {
      const screen = await render(
        <PlCodeBlock code={code} language="ts" toolbar={false} highlight={false} />
      );

      expect(screen.getByRole('button').query()).toBeNull();
      expect(screen.getByText('typescript').query()).toBeNull();
    });

    it('offers the raw toggle only when it was asked for', async () => {
      const screen = await render(<PlCodeBlock code={code} language="ts" />);

      expect(screen.getByRole('button', { name: 'Raw' }).query()).toBeNull();

      await screen.rerender(<PlCodeBlock code={code} language="ts" rawToggle />);

      await expect.element(screen.getByRole('button', { name: 'Raw' })).toBeInTheDocument();
    });

    it('presses the raw toggle down', async () => {
      const screen = await render(<PlCodeBlock code={code} language="ts" rawToggle />);
      const toggle = screen.getByRole('button', { name: 'Raw' });

      expect(toggle.element()).toHaveAttribute('aria-pressed', 'false');

      await toggle.click();

      await expect.element(toggle).toHaveAttribute('aria-pressed', 'true');
    });

    it('has no raw toggle to offer when nothing is coloured', async () => {
      const screen = await render(
        <PlCodeBlock code={code} language="ts" rawToggle highlight={false} />
      );

      expect(screen.getByRole('button', { name: 'Raw' }).query()).toBeNull();
    });
  });

  describe('copying', () => {
    it('puts the code on the clipboard and says so', async () => {
      const write = vi.fn().mockResolvedValue(undefined);

      vi.spyOn(navigator.clipboard, 'writeText').mockImplementation(write);

      const onCopy = vi.fn();
      const screen = await render(<PlCodeBlock code={code} highlight={false} onCopy={onCopy} />);

      await screen.getByRole('button').click();

      expect(write).toHaveBeenCalledWith('const answer = 42;\nconsole.log(answer);');
      expect(onCopy).toHaveBeenCalledWith('const answer = 42;\nconsole.log(answer);');
      await expect.element(screen.getByRole('button')).toHaveTextContent('Copied');

      vi.restoreAllMocks();
    });

    it('says so when the clipboard refused', async () => {
      vi.spyOn(navigator.clipboard, 'writeText').mockRejectedValue(new Error('denied'));
      vi.spyOn(document, 'execCommand').mockReturnValue(false);

      const onCopy = vi.fn();
      const screen = await render(<PlCodeBlock code={code} highlight={false} onCopy={onCopy} />);

      await screen.getByRole('button').click();

      await expect.element(screen.getByRole('button')).toHaveTextContent('Could not copy');
      expect(onCopy).not.toHaveBeenCalled();

      vi.restoreAllMocks();
    });

    it('takes its own words for the button', async () => {
      const screen = await render(
        <PlCodeBlock code={code} highlight={false} copyLabel="Take it" />
      );

      await expect.element(screen.getByRole('button')).toHaveTextContent('Take it');
    });

    it('offers no button when it is not copyable', async () => {
      const screen = await render(<PlCodeBlock code={code} highlight={false} copyable={false} />);

      expect(screen.getByRole('button').query()).toBeNull();
    });
  });

  describe('the gutter', () => {
    it('numbers nothing by default', async () => {
      await render(<PlCodeBlock code={code} highlight={false} />);

      expect(document.querySelector('.plass-code-line[data-line]')).toBeNull();
    });

    it('numbers the lines when it is asked', async () => {
      await render(<PlCodeBlock code={code} highlight={false} lineNumbers />);

      const numbers = Array.from(document.querySelectorAll<HTMLElement>('.plass-code-line')).map(
        (node) => node.dataset.line
      );

      expect(numbers).toEqual(['1', '2']);
    });

    it('starts where it was told to', async () => {
      await render(<PlCodeBlock code={code} highlight={false} lineNumbers startLine={286} />);

      const numbers = Array.from(document.querySelectorAll<HTMLElement>('.plass-code-line')).map(
        (node) => node.dataset.line
      );

      expect(numbers).toEqual(['286', '287']);
    });

    it('widens the gutter to the last number', async () => {
      await render(<PlCodeBlock code={'a\nb\nc'} highlight={false} lineNumbers startLine={99} />);

      expect(
        (document.querySelector('.plass-code') as HTMLElement).style.getPropertyValue(
          '--p-code-gutter'
        )
      ).toBe('3ch');
    });
  });

  describe('marked lines', () => {
    const marks = () =>
      Array.from(document.querySelectorAll<HTMLElement>('.plass-code-line')).map((node) =>
        node.hasAttribute('data-mark')
      );

    it('marks one line from a number', async () => {
      await render(<PlCodeBlock code={'a\nb\nc'} highlight={false} highlightLines={2} />);

      expect(marks()).toEqual([false, true, false]);
    });

    it('marks a range from a string', async () => {
      await render(<PlCodeBlock code={'a\nb\nc\nd'} highlight={false} highlightLines="2-3" />);

      expect(marks()).toEqual([false, true, true, false]);
    });

    it('marks a list of lines and ranges', async () => {
      await render(<PlCodeBlock code={'a\nb\nc\nd\ne'} highlight={false} highlightLines="1,3-4" />);

      expect(marks()).toEqual([true, false, true, true, false]);
    });

    it('reads a range written the wrong way round', async () => {
      await render(<PlCodeBlock code={'a\nb\nc\nd'} highlight={false} highlightLines="3-2" />);

      expect(marks()).toEqual([false, true, true, false]);
    });

    it('drops what it cannot read rather than throwing', async () => {
      await render(
        <PlCodeBlock code={'a\nb\nc'} highlight={false} highlightLines={['nonsense', 2]} />
      );

      expect(marks()).toEqual([false, true, false]);
    });

    it('counts the way the gutter counts', async () => {
      await render(
        <PlCodeBlock
          code={'a\nb\nc'}
          highlight={false}
          lineNumbers
          startLine={286}
          highlightLines={287}
        />
      );

      expect(marks()).toEqual([false, true, false]);
    });
  });

  describe('the prompt', () => {
    it('puts one in front of every line that has something on it', async () => {
      await render(<PlCodeBlock code={'npm i\n\nnpm test'} highlight={false} prompt="$" />);

      const prompts = Array.from(document.querySelectorAll<HTMLElement>('.plass-code-line')).map(
        (node) => node.dataset.prompt
      );

      expect(prompts).toEqual(['$', undefined, '$']);
    });

    it('leaves it out of what the clipboard is given', async () => {
      const write = vi.fn().mockResolvedValue(undefined);

      vi.spyOn(navigator.clipboard, 'writeText').mockImplementation(write);

      const screen = await render(<PlCodeBlock code="npm i" highlight={false} prompt="$" />);

      await screen.getByRole('button').click();

      expect(write).toHaveBeenCalledWith('npm i');

      vi.restoreAllMocks();
    });
  });

  describe('highlighting', () => {
    it('colours the code once the grammar has landed', async () => {
      await render(<PlCodeBlock code={code} language="ts" />);

      await expect.poll(() => document.querySelector('.hljs-keyword')?.textContent).toBe('const');
    });

    it('draws a language nothing knows plain rather than refusing it', async () => {
      await render(<PlCodeBlock code={code} language="brainfuck" />);

      expect(lines()).toEqual(['const answer = 42;', 'console.log(answer);']);
    });

    it('understands a file extension', async () => {
      await render(<PlCodeBlock code={'final int a = 1;'} language="dart" />);

      await expect.poll(() => document.querySelectorAll('.hljs-keyword').length).toBeGreaterThan(0);
    });

    it('drops the colouring while raw is pressed', async () => {
      const screen = await render(<PlCodeBlock code={code} language="ts" rawToggle />);

      await expect.poll(() => document.querySelector('.hljs-keyword')).not.toBeNull();

      await screen.getByRole('button', { name: 'Raw' }).click();

      await expect.poll(() => document.querySelector('.hljs-keyword')).toBeNull();
      expect(lines()).toEqual(['const answer = 42;', 'console.log(answer);']);
    });

    it('keeps a token that spans two lines coloured on both', async () => {
      await render(<PlCodeBlock code={'/* one\n   two */\nconst a = 1;'} language="ts" />);

      await expect.poll(() => document.querySelectorAll('.hljs-comment').length).toBeGreaterThan(1);
    });
  });

  describe('layout', () => {
    it('says when it is wrapping', async () => {
      await render(<PlCodeBlock code={code} highlight={false} wrap />);

      expect(document.querySelector('.plass-code')).toHaveAttribute('data-code-wrap', 'true');
    });

    it('bounds its own height', async () => {
      await render(<PlCodeBlock code={code} highlight={false} maxHeight={120} />);

      expect((document.querySelector('[role="region"]') as HTMLElement).style.maxHeight).toBe(
        '120px'
      );
    });

    it('takes a typeface and a size of its own', async () => {
      await render(<PlCodeBlock code={code} highlight={false} fontFamily="Menlo" fontSize={11} />);

      const block = document.querySelector('.plass-code') as HTMLElement;

      expect(block.style.fontFamily).toBe('Menlo');
      expect(block.style.fontSize).toBe('11px');
    });
  });
});
