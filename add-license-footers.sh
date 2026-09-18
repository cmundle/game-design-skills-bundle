#!/usr/bin/env bash
#
# Appends a licence footer to every SKILL.md in the repository.
#
# Skills get copied out of the repo one folder at a time, so each SKILL.md
# needs to carry its own licence line. The footer goes at the end of the file
# so it never touches the YAML frontmatter that agents parse.
#
# Safe to run more than once: files that already carry the marker are skipped.
#
# Usage, from the repository root:
#   bash add-license-footers.sh          # apply
#   bash add-license-footers.sh --dry    # list what would change, write nothing

set -euo pipefail

MARKER="<!-- license-footer -->"
DRY=0
[[ "${1:-}" == "--dry" ]] && DRY=1

IFS= read -r -d '' FOOTER <<'EOF' || true

---

<!-- license-footer -->
Part of the Game Design Skills Bundle by Stanislav Stankovic.
Licensed under PolyForm Noncommercial 1.0.0 — free for personal, academic and
nonprofit use. Commercial use requires a licence, sold as skill packs. See
<https://github.com/Stanestane/game-design-skills-bundle> for terms.

Required Notice: Copyright Stanislav Stankovic (https://www.stane-island.net/)
EOF

if [[ ! -d .git ]]; then
  echo "error: run this from the repository root (no .git here)" >&2
  exit 1
fi

added=0
skipped=0

while IFS= read -r -d '' file; do
  if grep -qF "$MARKER" "$file"; then
    skipped=$((skipped + 1))
    continue
  fi
  if [[ $DRY -eq 1 ]]; then
    echo "would add: $file"
  else
    # ensure the file ends with a newline, or the footer's blank line is
    # absorbed and the --- below turns the last line into a setext heading
    [[ -n $(tail -c 1 "$file") ]] && printf '\n' >> "$file"
    printf '%s\n' "$FOOTER" >> "$file"
    echo "added: $file"
  fi
  added=$((added + 1))
done < <(find . -name 'SKILL.md' -not -path './.git/*' -print0 | sort -z)

echo
if [[ $DRY -eq 1 ]]; then
  echo "dry run: $added file(s) would change, $skipped already carry the footer"
else
  echo "done: $added file(s) updated, $skipped already carried the footer"
fi

if [[ -d package-skills ]]; then
  echo
  echo "note: package-skills/ holds prebuilt .skill archives."
  echo "Repackage them so the archived copies carry the footer too."
fi
