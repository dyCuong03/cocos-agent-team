#!/usr/bin/env bash
SESSION_NAME="${SESSION_NAME:-cocos-team}"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Attaching to session: $SESSION_NAME"
  tmux attach -t "$SESSION_NAME"
else
  echo "Session '$SESSION_NAME' not found."
  echo "Launch it first: ./tmux/session.sh"
  exit 1
fi
