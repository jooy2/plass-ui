import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlChatBubble } from 'plass-ui';

describe('PlChatBubble', () => {
  describe('the message', () => {
    it('renders what was said', async () => {
      const screen = await render(<PlChatBubble>On my way.</PlChatBubble>);

      await expect.element(screen.getByText('On my way.')).toBeInTheDocument();
    });

    it('renders the sender and the time above it', async () => {
      const screen = await render(
        <PlChatBubble name="Ada" time="09:12">
          On my way.
        </PlChatBubble>
      );

      await expect.element(screen.getByText('Ada')).toBeInTheDocument();
      await expect.element(screen.getByText('09:12')).toBeInTheDocument();
    });

    it('reflects a changed message on re-render', async () => {
      const screen = await render(<PlChatBubble>Before</PlChatBubble>);

      await screen.rerender(<PlChatBubble>After</PlChatBubble>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlChatBubble className="my-own-class">Hi</PlChatBubble>);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('forwards unknown props to the row', async () => {
      const screen = await render(<PlChatBubble data-testid="message">Hi</PlChatBubble>);

      expect(screen.getByTestId('message').element()).toBeInTheDocument();
    });
  });

  describe('side', () => {
    it('runs the row the other way at the end', async () => {
      await render(
        <PlChatBubble className="bubble-under-test" side="end">
          Mine
        </PlChatBubble>
      );

      expect(document.querySelector('.bubble-under-test')).toHaveClass('flex-row-reverse');
    });

    it('starts at the start', async () => {
      await render(<PlChatBubble className="bubble-under-test">Theirs</PlChatBubble>);

      expect(document.querySelector('.bubble-under-test')).not.toHaveClass('flex-row-reverse');
    });
  });

  describe('status', () => {
    it('draws nothing when it is not given', async () => {
      const screen = await render(<PlChatBubble>Hi</PlChatBubble>);

      expect(screen.getByText('Sent').query()).toBeNull();
    });

    it('reads the mark out as a word', async () => {
      const screen = await render(<PlChatBubble status="delivered">Hi</PlChatBubble>);

      await expect.element(screen.getByText('Delivered')).toBeInTheDocument();
    });

    it('takes a word of its own', async () => {
      const screen = await render(
        <PlChatBubble status="read" statusLabel="읽음">
          Hi
        </PlChatBubble>
      );

      await expect.element(screen.getByText('읽음')).toBeInTheDocument();
    });

    it('changes the mark when the status moves', async () => {
      const screen = await render(<PlChatBubble status="sending">Hi</PlChatBubble>);

      await screen.rerender(<PlChatBubble status="read">Hi</PlChatBubble>);

      await expect.element(screen.getByText('Read')).toBeInTheDocument();
      expect(screen.getByText('Sending').query()).toBeNull();
    });
  });

  describe('typing', () => {
    it('draws the dots instead of the message', async () => {
      const screen = await render(<PlChatBubble typing>On my way.</PlChatBubble>);

      // The dots are a live region; what it announces is its own text, so
      // that is what a test looks for rather than an accessible name.
      await expect.element(screen.getByRole('status')).toBeInTheDocument();
      await expect.element(screen.getByText('Typing…')).toBeInTheDocument();
      expect(screen.getByText('On my way.').query()).toBeNull();
    });

    it('gives the message back when it stops', async () => {
      const screen = await render(<PlChatBubble typing>On my way.</PlChatBubble>);

      await screen.rerender(<PlChatBubble>On my way.</PlChatBubble>);

      await expect.element(screen.getByText('On my way.')).toBeInTheDocument();
      expect(screen.getByRole('status').query()).toBeNull();
    });

    it('takes a word of its own', async () => {
      const screen = await render(
        <PlChatBubble typing typingLabel="입력 중…">
          Later
        </PlChatBubble>
      );

      await expect.element(screen.getByText('입력 중…')).toBeInTheDocument();
    });
  });

  describe('the link preview', () => {
    it('renders a real link with the title and the site', async () => {
      const screen = await render(
        <PlChatBubble
          preview={{
            url: 'https://example.com/notes',
            title: 'Notes on glass',
            site: 'example.com',
            description: 'What a sheet is made of.'
          }}
        >
          Look at this
        </PlChatBubble>
      );

      const link = screen.getByRole('link');

      expect(link.element()).toHaveAttribute('href', 'https://example.com/notes');
      await expect.element(screen.getByText('Notes on glass')).toBeInTheDocument();
      await expect.element(screen.getByText('example.com')).toBeInTheDocument();
    });

    it('protects the opener on a new-tab card', async () => {
      const screen = await render(
        <PlChatBubble preview={{ url: 'https://example.com', title: 'Elsewhere', newTab: true }}>
          Look
        </PlChatBubble>
      );

      const link = screen.getByRole('link').element();

      expect(link).toHaveAttribute('target', '_blank');
      expect(link).toHaveAttribute('rel', 'noopener noreferrer');
    });
  });

  describe('the slots', () => {
    it('renders the media and the actions', async () => {
      const screen = await render(
        <PlChatBubble
          media={<img src="/logo.svg" alt="A logo" />}
          actions={<button type="button">More</button>}
        >
          Look
        </PlChatBubble>
      );

      await expect.element(screen.getByRole('img', { name: 'A logo' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'More' })).toBeInTheDocument();
    });
  });
});
