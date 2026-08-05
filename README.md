# danger

A zsh function that launches [Claude Code](https://claude.com/claude-code) with
`--dangerously-skip-permissions` — but not before flashing a suitably dramatic
warning: a bouncing block-letter **DANGER!** banner while a swarm of little
Claude logos pops in at random spots around it.

![danger in action](danger.gif)

The letters ripple up and down in a wave and the Claudes appear one by
one — every run scatters them differently.

## Install

Clone the repo and source it from your `.zshrc`:

```sh
git clone https://github.com/noahcoffey/danger.git ~/danger
echo 'source ~/danger/danger.zsh' >> ~/.zshrc
```

Then:

```sh
danger            # animation, then: claude --dangerously-skip-permissions
danger "fix it"   # extra args are passed through to claude
```

Ctrl-c during the animation aborts without launching claude.

## Requirements

- zsh
- [Claude Code](https://claude.com/claude-code) (`claude` on your PATH)
- A terminal at least ~78 columns wide (narrower terminals will wrap the art)

## A word of warning

`--dangerously-skip-permissions` does exactly what it says: Claude Code runs
without asking permission for edits or commands. The animation is the point —
a moment of ceremony before handing over the keys. Use in directories you
trust losing.
