---
name: dotter-manager
description: Manage dotfiles using Dotter. Use for deploying configurations, adding new packages, debugging templates, and managing global/local configs.
---

# Dotter Manager

This skill helps you manage the dotfiles repository using Dotter.

## Core Workflows

### 1. Deploy Changes
Always test with dry-run first.

```bash
# Preview changes
dotter deploy --dry-run

# Apply changes
dotter deploy -v

# Force apply (overwrite)
dotter deploy -f
```

### 2. Add New Configuration
1.  Move config to repo: `mv ~/.config/app ./app`
2.  Edit `.dotter/global.toml`:
    ```toml
    [app.files]
    "app/config" = "~/.config/app/config"
    ```
3.  Test: `dotter deploy --dry-run`

### 3. Machine-Specific Config
Edit `.dotter/local.toml` (do not commit this file):

```toml
packages = ["default", "app"] # Select active packages

[variables]
theme = "light" # Override global variables
```

### 4. Templating & Syntax
See [syntax.md](references/syntax.md) for Handlebars and TOML reference.
For deep details, check `docs/dotter-templates.md` in the repo.

## Troubleshooting

- **Variable not found**: Check `global.toml` [variables] section or `local.toml`.
- **Symlink failed**: Use `-f` to force overwrite if file exists.
- **Template not rendering**: Ensure file has `{{` or set `type = "template"` in toml.
- **Debug**: Use `dotter deploy -vv` for verbose logs.
