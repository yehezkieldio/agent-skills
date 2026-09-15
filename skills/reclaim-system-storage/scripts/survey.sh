#!/usr/bin/env bash
# Survey disk usage before any cleanup decision. Read-only — deletes nothing.
# Usage: scripts/survey.sh [depth]  (depth defaults to 1, passed to dust -d)
set -euo pipefail

DEPTH="${1:-1}"

echo "=== disk free ==="
df -h / 2>/dev/null || true

echo
echo "=== home directory, depth $DEPTH (dust preferred, du fallback) ==="
if command -v dust >/dev/null 2>&1; then
	dust -d "$DEPTH" "$HOME" 2>/dev/null | tail -40
else
	du -sh "$HOME"/* "$HOME"/.[a-zA-Z]* 2>/dev/null | sort -rh | head -40
fi

echo
echo "=== ~/.cache breakdown (top-level dirs) ==="
du -sh "$HOME"/.cache/* 2>/dev/null | sort -rh | head -30

echo
echo "=== ~/.local/share breakdown ==="
du -sh "$HOME"/.local/share/* 2>/dev/null | sort -rh | head -20

echo
echo "=== ~/.config breakdown (top 15) ==="
du -sh "$HOME"/.config/* 2>/dev/null | sort -rh | head -15

echo
echo "=== package manager caches (system, needs sudo to clear) ==="
du -sh /var/cache/pacman/pkg 2>/dev/null || true
echo "orphaned packages: $(pacman -Qtdq 2>/dev/null | wc -l)"

echo
echo "=== journal size ==="
journalctl --disk-usage 2>/dev/null || true

echo
echo "=== trash ==="
du -sh "$HOME"/.local/share/Trash 2>/dev/null || true
