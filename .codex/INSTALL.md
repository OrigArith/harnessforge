# Installing HarnessForge for Codex

HarnessForge is a Codex plugin. Install it by registering it in a local marketplace.

## Prerequisites

- Git
- Codex CLI 0.1+

## Personal Install (available across all repos)

1. **Clone into the Codex plugins directory:**
   ```bash
   git clone https://github.com/OrigArith/harnessforge.git ~/.codex/plugins/harnessforge
   ```

2. **Register in your personal marketplace:**

   If `~/.agents/plugins/marketplace.json` does not exist, create it:
   ```bash
   mkdir -p ~/.agents/plugins
   cat > ~/.agents/plugins/marketplace.json << 'EOF'
   {
     "name": "local-plugins",
     "interface": { "displayName": "Local Plugins" },
     "plugins": [
       {
         "name": "forge",
         "source": { "source": "local", "path": "./../../.codex/plugins/harnessforge" },
         "policy": { "installation": "AVAILABLE", "authentication": "NONE" },
         "category": "Developer Tools"
       }
     ]
   }
   EOF
   ```

   If the file already exists, add the `forge` entry to the `plugins` array.

3. **Restart Codex** (quit and relaunch the CLI) to discover the plugin.

4. **Install the plugin** from the Plugin Directory (`/plugins` in CLI, or browse in app).

## Repo-Scoped Install (available only in one repo)

1. **Clone into the repo's plugins directory:**
   ```bash
   mkdir -p ./plugins
   cp -R /path/to/harnessforge ./plugins/harnessforge
   ```

2. **Register in the repo marketplace:**
   ```bash
   mkdir -p .agents/plugins
   cat > .agents/plugins/marketplace.json << 'EOF'
   {
     "name": "repo-plugins",
     "interface": { "displayName": "Repo Plugins" },
     "plugins": [
       {
         "name": "forge",
         "source": { "source": "local", "path": "./plugins/harnessforge" },
         "policy": { "installation": "INSTALLED_BY_DEFAULT", "authentication": "NONE" },
         "category": "Developer Tools"
       }
     ]
   }
   EOF
   ```

3. **Restart Codex** to discover the plugin.

## Verify

Open Codex and check the Plugin Directory (`/plugins`). HarnessForge should appear as "forge" with 5 skills.

You can also use `@forge` to explicitly invoke the plugin or its skills.

## Updating

```bash
cd ~/.codex/plugins/harnessforge && git pull
```

Restart Codex to pick up changes.

## Uninstalling

1. Remove the plugin entry from `~/.agents/plugins/marketplace.json`.
2. Delete the clone: `rm -rf ~/.codex/plugins/harnessforge`.
3. Restart Codex.
