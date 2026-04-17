# OpenCode Bootstrap

This repo is the source of truth for a shareable OpenCode setup. Clone it anywhere and use `make` to install the runtime config into `~/.config/opencode`.

## Base install

```bash
make install
```

This command:
- creates `~/.config/opencode.local.env` from the example template if it is missing
- installs agents, vendored skills, prompts, instructions, commands, and wrapper scripts into `~/.config/opencode`
- renders `~/.config/opencode/opencode.json`

## Validation

```bash
make check
```

Runs prerequisite checks without mutating the install.

## Reinstall

```bash
make reinstall
```

Forces a full reinstall into `~/.config/opencode`.

## Optional services

Install the OpenCode server service for the current platform:

```bash
make install-service
```

Install Telegram support for the current platform:

```bash
make install-telegram
```

Platform service backends:
- macOS: `launchd`
- Linux: `systemd --user`

## Local overrides

Runtime-specific settings live in:

```bash
~/.config/opencode.local.env
```

Optional Telegram secrets live in:

```bash
~/.config/opencode/telegram-bot.env
```

The installer creates both example files automatically when needed.
