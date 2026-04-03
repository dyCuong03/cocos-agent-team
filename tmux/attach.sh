#!/usr/bin/env bash
SESSION_NAME="${SESSION_NAME:-playable-team}"
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  tmux attach -t "$SESSION_NAME"
else
  echo "Session '$SESSION_NAME' not running."
  echo "Launch first: ./tmux/session.sh"
  exit 1
fi
