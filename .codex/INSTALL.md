# Installing HarnessForge for Codex

Enable HarnessForge skills in Codex via native skill discovery. Clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the HarnessForge repository:**
   ```bash
   git clone https://github.com/OrigArith/harnessforge.git ~/.codex/harnessforge
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/harnessforge/skills ~/.agents/skills/harnessforge
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## Verify

```bash
ls -la ~/.agents/skills/harnessforge
```

You should see a symlink pointing to your HarnessForge skills directory.

## Updating

```bash
cd ~/.codex/harnessforge && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/harnessforge
```

Optionally delete the clone: `rm -rf ~/.codex/harnessforge`.
