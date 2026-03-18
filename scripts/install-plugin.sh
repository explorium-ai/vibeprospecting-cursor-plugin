# Based on https://medium.com/@v.tajzich/how-to-write-and-test-cursor-plugins-locally-the-part-the-docs-dont-tell-you-4eee705d7f76

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_NAME="vibe-prospecting"
PLUGIN_ID="${PLUGIN_NAME}@local"
PLUGIN_SOURCE="$REPO_ROOT/plugins/$PLUGIN_NAME"
TARGET="$HOME/.cursor/plugins/$PLUGIN_NAME"
CLAUDE_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ ! -d "$PLUGIN_SOURCE" ]]; then
  echo "Error: Plugin source not found at $PLUGIN_SOURCE"
  exit 1
fi

# 0. Remove old/legacy plugin installations
rm -rf "$HOME/.cursor/plugins/my-plugin"
python3 - "$CLAUDE_PLUGINS" "$CLAUDE_SETTINGS" <<'PY'
import json, os, sys
plugins_path, settings_path = sys.argv[1], sys.argv[2]
for pid in ["my-plugin@local", "my-plugin"]:
    if os.path.exists(plugins_path):
        try:
            data = json.load(open(plugins_path))
            plugins = data.get("plugins", {})
            if pid in plugins:
                del plugins[pid]
                data["plugins"] = plugins
                json.dump(data, open(plugins_path, "w"), indent=2)
        except Exception:
            pass
    if os.path.exists(settings_path):
        try:
            data = json.load(open(settings_path))
            enabled = data.get("enabledPlugins", {})
            if pid in enabled:
                del enabled[pid]
                data["enabledPlugins"] = enabled
                json.dump(data, open(settings_path, "w"), indent=2)
        except Exception:
            pass
PY

# 1. Copy plugin files
rm -rf "$TARGET"
mkdir -p "$HOME/.claude/plugins"
cp -R "$PLUGIN_SOURCE" "$TARGET"
# 2. Register in installed_plugins.json (upsert, don't clobber)
python3 - "$CLAUDE_PLUGINS" "$PLUGIN_ID" "$TARGET" <<'PY'
import json, os, sys
path, pid, ipath = sys.argv[1], sys.argv[2], sys.argv[3]
data = {}
if os.path.exists(path):
    try: data = json.load(open(path))
    except: data = {}
plugins = data.get("plugins", {})
entries = [e for e in plugins.get(pid, [])
           if not (isinstance(e, dict) and e.get("scope") == "user")]
entries.insert(0, {"scope": "user", "installPath": ipath})
plugins[pid] = entries
data["plugins"] = plugins
os.makedirs(os.path.dirname(path), exist_ok=True)
json.dump(data, open(path, "w"), indent=2)
PY
# 3. Enable in settings.json (upsert, don't clobber)
python3 - "$CLAUDE_SETTINGS" "$PLUGIN_ID" <<'PY'
import json, os, sys
path, pid = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    try: data = json.load(open(path))
    except: data = {}
data.setdefault("enabledPlugins", {})[pid] = True
os.makedirs(os.path.dirname(path), exist_ok=True)
json.dump(data, open(path, "w"), indent=2)
PY
echo "Installed. Restart Cursor."