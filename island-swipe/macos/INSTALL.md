# Activity Monitor macOS Install Guide for Coding Agents

Use this document when a coding agent needs to install and run the macOS app from source on its own Mac.

## Goal

Install `Activity Monitor.app` into the current user's application directory:

```bash
~/Applications/Activity Monitor.app
```

Use `/tmp/front-simple-screen-monitor` as the default temporary clone/build directory.

## Preconditions

- macOS 14 or newer
- Apple Silicon Mac
- Apple developer tools available

If command line tools are missing:

```bash
xcode-select --install
```

## Preferred Path

Run exactly this sequence:

```bash
cd /tmp
rm -rf front-simple-screen-monitor
git clone https://github.com/liush2yuxjtu/front-simple-screen-monitor.git
cd /tmp/front-simple-screen-monitor/island-swipe/macos
chmod +x script/*.sh
./script/install_app.sh --user
open "$HOME/Applications/Activity Monitor.app"
```

Expected result:

- source lives in `/tmp/front-simple-screen-monitor`
- app is installed at `~/Applications/Activity Monitor.app`
- Finder opens the installed app when requested

## Validation

If you need to verify build and interaction logic before install:

```bash
cd /tmp/front-simple-screen-monitor/island-swipe/macos
./script/self_check.sh
```

Expected output:

```bash
SELF CHECK PASSED
```

If you need to verify the debug run path:

```bash
./script/build_and_run.sh --verify
```

## Manual Steps

If you need a slower step-by-step path instead of the preferred one:

```bash
cd /tmp
rm -rf front-simple-screen-monitor
git clone https://github.com/liush2yuxjtu/front-simple-screen-monitor.git
cd /tmp/front-simple-screen-monitor/island-swipe/macos
chmod +x script/*.sh
./script/self_check.sh
./script/build_and_run.sh
./script/install_app.sh --user
```

## Runtime Commands

Normal run:

```bash
./script/build_and_run.sh
```

Debug run:

```bash
./script/build_and_run.sh --debug
```

Logs:

```bash
./script/build_and_run.sh --logs
```

Verify process launch:

```bash
./script/build_and_run.sh --verify
```

## Operational Notes

- Treat `/tmp/front-simple-screen-monitor` as disposable staging only.
- The persistent artifact is `~/Applications/Activity Monitor.app`.
- If `/tmp` is cleaned later, the installed app in `~/Applications` should remain.

## Boundaries

- Current build output is `arm64` only.
- Current minimum OS is macOS 14.
- This path is intended for developers or coding agents building locally from source.
- The locally installed app is appropriate for self-use on the same machine.
- This document is not the distribution path for non-technical end users.
