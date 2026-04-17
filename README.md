# OpenCode Distro

This repository is a curated OpenCode distro: a tested setup you can install, keep updating, and share with other developers.

It packages a practical baseline of configuration, agents, prompts, commands, skills, and service templates so a developer can get to a reliable OpenCode environment without building everything from scratch.

## Who This Is For

- Developers who want a stable OpenCode starting point
- Teams that want a reusable setup they can evolve over time
- Power users who want a curated baseline and then optional integrations on top

## What It Installs

Running the bootstrap installs runtime assets into your local OpenCode config directory and renders `opencode.json` from templates plus local overrides.

Main outputs:

- `~/.config/opencode/opencode.json`
- `~/.config/opencode/agents/`
- `~/.config/opencode/skills/`
- `~/.config/opencode/bin/`
- `~/.config/opencode/telegram-bot.env.example`
- `~/.config/opencode/telegram-bot.env` when Telegram support is initialized

## Baseline Install

```bash
make install
make check
```

- `make install`: install the distro into `~/.config/opencode`
- `make check`: validate prerequisites without changing installed files

Optional services:

```bash
make install-service
make install-telegram
```

- `make install-service`: install the OpenCode server as a background user service so it stays available outside the terminal session
- `make install-telegram`: install the Telegram bot integration as a background user service after you configure `~/.config/opencode/telegram-bot.env`

## Layout

- `agents/`: agent definitions used by the distro
- `skills/`: vendored skills and supporting assets
- `prompts/`, `instructions/`, `commands/`: reusable operational content
- `bin/`: wrapper scripts used by generated config and local MCP tools
- `templates/`: source templates for `opencode.json`, env examples, and service definitions
- `scripts/`: bootstrap and rendering scripts for install and service setup

## MCPs and Integrations

This distro supports a curated MCP baseline and optional integrations.

- Start with the distro install
- Enable only the MCPs you actually use
- Read [MCP_SERVERS.md](./MCP_SERVERS.md) before turning on optional MCP integrations

That guide covers recommended MCPs, prerequisites, env flags, and when an integration needs external setup before this repo can use it.

## Platforms

The bootstrap supports:

- macOS with `launchd`
- Linux with `systemd --user`

## Docs

- [INSTALL.md](./INSTALL.md): installation and validation flow
- [MCP_SERVERS.md](./MCP_SERVERS.md): curated MCP recommendations and setup guidance
- [REMOTE_TELEGRAM_SETUP.md](./REMOTE_TELEGRAM_SETUP.md): Telegram-only remote control setup

## Local Overrides

After the base install, fill in local secrets and overrides in:

- `~/.config/opencode.local.env`
- `~/.config/opencode/telegram-bot.env`

## Notes

- This repository stores distro templates and install logic, not live secrets.
- The bootstrap reads template files from `templates/`, then copies or renders them into your local OpenCode config directory.
