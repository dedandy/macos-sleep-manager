#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/version.sh"

usage() {
  echo "Usage: $0 [patch|minor|major|--sync]" >&2
  exit 1
}

[ -f "$VERSION_FILE" ] || { echo "Missing $VERSION_FILE" >&2; exit 1; }
# shellcheck disable=SC1090
source "$VERSION_FILE"

if [ -z "${SM_VERSION:-}" ]; then
  echo "SM_VERSION not set in $VERSION_FILE" >&2
  exit 1
fi

sync_version() {
  local v="$1"
  perl -pi -e "s/^# \/\.sleep v\d+\.\d+\.\d+/# \/\.sleep v$v/" "$ROOT_DIR/sleep"
  perl -pi -e "s/^# \/\.wakeup v\d+\.\d+\.\d+/# \/\.wakeup v$v/" "$ROOT_DIR/wakeup"
  perl -pi -e "s/^# \/\.sleeplog v\d+\.\d+\.\d+/# \/\.sleeplog v$v/" "$ROOT_DIR/sleeplog"
  perl -pi -e "s/^# install\.sh v\d+\.\d+\.\d+/# install.sh v$v/" "$ROOT_DIR/install.sh"
  perl -pi -e "s/^# macOS Sleep Manager v\d+\.\d+(\.\d+)?/# macOS Sleep Manager v$v/" "$ROOT_DIR/config.template"
  perl -pi -e "s/^# uninstall\.sh v\d+\.\d+\.\d+/# uninstall.sh v$v/" "$ROOT_DIR/uninstall.sh"
  perl -pi -e "s/^# MASTER_INSTALL v\d+\.\d+\.\d+/# MASTER_INSTALL v$v/" "$ROOT_DIR/MASTER_INSTALL.sh"
  perl -pi -e "s/<bitbar\.version>v\d+\.\d+\.\d+/<bitbar.version>v$v/" "$ROOT_DIR/SleepManager.1m.sh"
  perl -pi -e "s/^# \/\.sleepmanager_editor v\d+\.\d+/# \/\.sleepmanager_editor v$v/" "$ROOT_DIR/config_editor"
  perl -pi -e "s/EDITOR v\d+\.\d+/EDITOR v$v/" "$ROOT_DIR/config_editor"
  perl -pi -e "s/^# \/\.config_editor_auto v\d+\.\d+/# \/\.config_editor_auto v$v/" "$ROOT_DIR/config_editor_auto"
  perl -pi -e "s/^# macOS Sleep Manager v\d+\.\d+\.\d+/# macOS Sleep Manager v$v/" "$ROOT_DIR/install.sh"
}

case "${1:-}" in
  --sync)
    sync_version "$SM_VERSION"
    exit 0
    ;;
  patch|minor|major)
    ;;
  *)
    usage
    ;;
esac

IFS='.' read -r major minor patch <<< "$SM_VERSION"
case "$1" in
  patch) patch=$((patch + 1)) ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  major) major=$((major + 1)); minor=0; patch=0 ;;
  *) usage ;;
esac

NEW_VERSION="$major.$minor.$patch"
cat > "$VERSION_FILE" <<'EOS'
#!/bin/bash
# Central version for scripts and menus

SM_VERSION="REPLACE_VERSION"
EOS
perl -pi -e "s/REPLACE_VERSION/$NEW_VERSION/" "$VERSION_FILE"

sync_version "$NEW_VERSION"

echo "Bumped version to $NEW_VERSION"
