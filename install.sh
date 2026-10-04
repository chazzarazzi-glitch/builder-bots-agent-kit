#!/bin/bash
# Builder Bots Agent Kit, one line install for Mac and Linux.
#   curl -fsSL https://raw.githubusercontent.com/chazzarazzi-glitch/builder-bots-agent-kit/main/install.sh | bash -s yourname.agent
#   add  --folder  to build a bot folder (Claude Code, Codex, Cursor) instead of a Hermes bot
#   add  --token N  if your wallet holds more than one forged Builder Bot
# Reads public chain data only. No keys, no wallet access. Needs python3 and curl.
main() {
  set -e
  command -v python3 >/dev/null || { echo "python3 is needed. On a Mac, run: xcode-select --install"; exit 1; }
  local mode=hermes args=()
  for a in "$@"; do [ "$a" = "--folder" ] && mode=folder || args+=("$a"); done
  if [ "$mode" = hermes ] && [ ! -d "${HERMES_HOME:-$HOME/.hermes}" ]; then
    echo "Hermes isn't installed here, so building a bot folder instead."; mode=folder
  fi
  local tmp; tmp=$(mktemp -d)
  curl -fsSL "https://raw.githubusercontent.com/chazzarazzi-glitch/builder-bots-agent-kit/main/bb_kit.py" -o "$tmp/bb_kit.py"
  if [ -r /dev/tty ] && [ -t 1 ]; then python3 "$tmp/bb_kit.py" "$mode" "${args[@]}" < /dev/tty
  else python3 "$tmp/bb_kit.py" "$mode" "${args[@]}" < /dev/null; fi
  rm -rf "$tmp"
}
main "$@"
