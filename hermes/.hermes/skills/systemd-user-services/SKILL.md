---
name: systemd-user-services
description: "Use when creating or debugging systemd user services."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [systemd, linux, daemon, services]
---

# systemd User Services

Arvid wants his daemons to start at boot and survive crashes, with the unit files kept in the owning project's repo so a fresh machine is reproducible.

## Authoring rules

- **ExecStart executable paths must be absolute; `${HOME}` does NOT expand there.** For portable units use a shell wrapper — the shell expands `$HOME` in argument position at runtime:
  ```
  ExecStart=/bin/sh -c 'exec "$HOME/code/<project>/bin/daemon"'
  ```
- Keep units minimal and portable (no hardcoded user paths outside the wrapper). Store them in `<repo>/systemd/` next to the code they run, with a README section covering install.
- `Restart=on-failure` + `RestartSec=5` is the default for dev daemons.

## Install / verify

```bash
cp <repo>/systemd/*.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now <name>
systemd-analyze verify <unit-file>   # ALWAYS before enabling — catches bad-setting errors that only surface on restart
```

- Boot start without a login session: `sudo loginctl enable-linger $USER` (keeps the user manager alive at boot and after logout). Arvid's machines need this for headless operation.
- Logs: `journalctl --user -u <name> -f`. Child processes inherit stdout/stderr into the journal.

## Pitfalls

- **Check whether the current agent session depends on a service before restarting it** — e.g. Hermes running on a local model served by that service loses its own inference mid-turn. Schedule such restarts for when no turn is active, or hand the kill/restart to the user and resume with `hermes --continue`.
- A unit that fails `systemd-analyze verify` shows as `bad-setting` after daemon-reload and blocks restart of the *running* old instance — fix the file before reloading, not after.
