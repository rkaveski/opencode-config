# Telegram-Only OpenCode Remote Control

## What this setup does

- Runs a single persistent OpenCode server at `http://127.0.0.1:4096`
- Lets the Telegram bot talk to that same backend
- Lets your local TUI attach to that same backend
- Preserves the same OpenCode session across both clients

## New install flow

Clone the repo anywhere and use the one-command bootstrap:

```bash
make install
make install-service
make install-telegram
```

The base install writes the runtime config to `~/.config/opencode`.

Service backends:
- macOS: `launchd`
- Linux: `systemd --user`

## First-time setup

1. Create your Telegram bot with `@BotFather`
2. Get your Telegram numeric user ID from `@userinfobot`
3. Run `make install`
4. Fill in `~/.config/opencode/telegram-bot.env`
5. Run `make install-service`
6. Run `make install-telegram`

The installer creates these local files automatically when they are missing:
- `~/.config/opencode/telegram-bot.env`
- `~/.config/opencode/telegram-bot-home/settings.json`

## Daily use

Resume the same shared session locally:

```bash
opencode -s <session-id>
```

## macOS service commands

Status:

```bash
launchctl print "gui/$(id -u)/ai.opencode.server"
launchctl print "gui/$(id -u)/ai.opencode.telegram"
```

Restart:

```bash
launchctl kickstart -k "gui/$(id -u)/ai.opencode.server"
launchctl kickstart -k "gui/$(id -u)/ai.opencode.telegram"
```

Unload:

```bash
launchctl bootout "gui/$(id -u)/ai.opencode.server"
launchctl bootout "gui/$(id -u)/ai.opencode.telegram"
```

## Linux service commands

Status:

```bash
systemctl --user status ai.opencode.server.service
systemctl --user status ai.opencode.telegram.service
```

Restart:

```bash
systemctl --user restart ai.opencode.server.service
systemctl --user restart ai.opencode.telegram.service
```

Stop:

```bash
systemctl --user stop ai.opencode.server.service
systemctl --user stop ai.opencode.telegram.service
```

## Handoff rule

Use one device at a time for a given session. The session state is shared; transient UI state is not.
