# AGENTS.md

This repository contains personal dotfiles managed by [Dotter](https://github.com/SuperCuber/dotter). This guide is for AI agents working in this codebase.

## Project Overview

- **Purpose**: Personal configuration file repository
- **Manager**: Dotter (Rust-based dotfile manager with template engine)
- **Key Components**:
  - Shell configurations (Fish)
  - Editor configs (Helix, Alacritty, Kitty, Zed)
  - Development tools (Git, Tmux, Starship)
  - Package managers (Homebrew, UV, Rye, Conda)

## Commands

### Deployment (Primary Commands)

```bash
# Deploy all configurations
dotter deploy

# Skip brew hooks (fast deployment, skip package installation)
dotter deploy --pre-deploy "" --post-deploy ""

# Dry-run (preview changes without applying)
dotter deploy --dry-run

# Verbose deployment (show all changes)
dotter deploy -v

# Force overwrite
dotter deploy -f

# Undeploy all configurations
dotter undeploy

# Watch mode (auto-deploy on file changes)
dotter watch
```

### Testing/Linting

```bash
# No traditional unit tests - configuration files are tested by deployment

# Validate Dotter configuration
dotter deploy --dry-run

# Check TOML syntax (if python-toml or similar available)
python -m toml .dotter/global.toml
```

### Single File Testing

```bash
# Test a specific file deployment by creating a test package in local.toml
# Then: dotter deploy --dry-run

# Validate fish script syntax
fish -n fish/example.fish

# Validate shell script syntax
bash -n entrypoint.sh

# Validate TOML (requires toml-cli)
toml validate .dotter/global.toml
```

## File Structure

```
.
├── .dotter/              # Dotter configuration
│   ├── global.toml      # Global config (shared across machines)
│   ├── local.toml       # Local config (machine-specific, in .gitignore)
│   └── pre_deploy.sh    # Pre-deployment hook
├── config/              # Configuration files (organized by category)
│   ├── editors/         # Editor configurations
│   │   ├── terminals/   # Terminal configs (Alacritty, Kitty, WezTerm)
│   │   ├── helix/       # Helix editor config
│   │   ├── zed/         # Zed editor config
│   │   └── vim/         # Vim configuration
│   ├── shell/           # Shell configurations
│   │   └── fish/        # Fish shell scripts
│   ├── tools/           # Development tools
│   │   ├── git/         # Git configuration
│   │   ├── tmux.conf    # Tmux config
│   │   └── starship.toml # Starship prompt
│   ├── linters-formatters/  # Code quality tools
│   └── package-managers/    # Package manager configs
├── scripts/             # Executable scripts
│   └── entrypoint.sh    # Docker entrypoint
├── docs/                # Documentation
└── Dockerfile           # Container definition
```

## Code Style Guidelines

### Shell Scripts (Bash)

- **Shebang**: Always use `#!/usr/bin/env bash`
- **Error Handling**: Add `|| exit` after critical commands
- **Comments**: Use `#` for comments, keep them concise
- **Quoting**: Use double quotes for variables to handle spaces
- **Environment**: Set non-interactive flags in scripts:
  ```bash
  export CI=true
  export DEBIAN_FRONTEND=noninteractive
  export HOMEBREW_NO_AUTO_UPDATE=1
  ```

### Fish Scripts

- **Variables**:
  - Use `set -gx` for global exported variables
  - Use `set -g` for global variables (not exported)
  - Example: `set -gx EDITOR /opt/homebrew/bin/code`
- **Quotes**: Minimal usage - fish handles spaces well
- **Functions**: Define in `fish/functions/` directory
- **Style**: One-line variables preferred, no trailing semicolons

### TOML Files (Dotter Config)

- **Structure**: Sections defined with `[section]`
- **Arrays**: Use `=(item1 item2)` syntax in bash, arrays in TOML
- **Files Mapping**:
  ```toml
  [packagename.files]
  "source" = "~/.config/destination"
  ```
- **Variables**: Define in `[packagename.variables]` section

### Configuration Files

- **Editor**: Helix uses TOML (config.toml, languages.toml)
- **Terminal**: Alacritty uses YAML-like TOML
- **Package Managers**: Each uses their own format (JSON, TOML, etc.)
- **Pattern**: Keep configs minimal and focused on essential settings

## Naming Conventions

- **Directories**: Lowercase, no spaces (e.g., `fish/`, `helix/`)
- **Files**: 
  - Config files: Lowercase with dots (`.gitignore`, `alacritty.toml`)
  - Scripts: Executable, descriptive names (`entrypoint.sh`, `pre_deploy.sh`)
- **Variables**: UPPERCASE with underscores for environment variables (`EDITOR`, `PATH`)
- **Packages**: Lowercase, descriptive names in Dotter config (`default`, `alacritty`, `helix`)

## Error Handling

- **Shell Scripts**: Append `|| exit` to critical commands
- **Fish Scripts**: Use `|| exit` when called from shell scripts
- **Dotter**: Use `--dry-run` before actual deployment to catch errors
- **Configuration**: Test deployment on test machine or with `--dry-run` first

## Adding New Configurations

1. Move config file to appropriate `config/` subdirectory based on category:
   - Editors → `config/editors/`
   - Terminals → `config/editors/terminals/`
   - Shell → `config/shell/`
   - Tools → `config/tools/`
   - Linters/Formatters → `config/linters-formatters/`
   - Package Managers → `config/package-managers/`
2. Add mapping to `.dotter/global.toml`:
   ```toml
   [newtool.files]
   "config/category/config_file" = "~/.config/newtool/config"
   ```
3. Test: `dotter deploy --dry-run`
4. Deploy: `dotter deploy -v`
5. Commit changes

## Multi-Machine Configuration

- **Global config** (`.dotter/global.toml`): Shared across all machines
- **Local config** (`.dotter/local.toml`): Machine-specific, in `.gitignore`
- **Package selection**: Activate packages in `local.toml`:
  ```toml
  [packages]
  default = true
  helix = true
  alacritty = true
  ```

## Important Notes

- **Local config** should NEVER be committed - it's in `.gitignore`
- **Pre-deployment hooks** in `.dotter/pre_deploy.sh` run before every deployment
- **Post-deployment hooks** in `.dotter/post_deploy.sh` run after deployment and install Homebrew packages
- **Skip hooks**: Use `--pre-deploy ""` or `--post-deploy ""` to skip hooks (useful for quick config updates)
- **Symlinks**: Dotter creates symlinks automatically for files
- **Templates**: Use `{{variable}}` syntax in files for variable substitution
- **Cache**: Dotter caches deployments; use `-f` to force updates

## Skipping Brew Hooks

The pre/post deployment hooks automatically handle Homebrew installation and package management. To skip these for faster configuration-only deployment:

```bash
# Skip both brew checks and package installation
dotter deploy --pre-deploy "" --post-deploy ""

# Skip only package installation (keep brew check)
dotter deploy --post-deploy ""

# Use empty hook script (noop.sh provided in .dotter/)
dotter deploy --pre-deploy .dotter/noop.sh --post-deploy .dotter/noop.sh
```

## Common Patterns

### Fish Environment Variables
```fish
set -gx EDITOR /opt/homebrew/bin/code
set -gx FZF_DEFAULT_COMMAND "fd --type file --color=always"
```

### Dotter File Mapping
```toml
[package.files]
"config.toml" = "~/.config/app/config.toml"
"script.sh" = "~/.local/bin/script.sh"
```

### Shell Script with Error Handling
```bash
#!/usr/bin/env bash
command1 || exit
command2 || exit
```

## Testing Changes

Always test changes in this order:
1. `dotter deploy --dry-run` - verify syntax and file mappings
2. `dotter deploy -v` - apply changes with verbose output
3. Test actual tool functionality (e.g., open Helix to test config, run fish to verify shell setup)
4. Commit only after successful testing

## Directory Organization Philosophy

The `config/` directory organizes configurations by category rather than keeping all configs in the repository root:
- **Editors**: All editor-specific configs (Helix, Zed, Vim) are grouped together
- **Terminals**: Terminal emulator configs (Alacritty, Kitty, WezTerm) in one place
- **Shell**: Shell configurations (Fish) separated from other configs
- **Tools**: Development tools (Git, Tmux, Starship) grouped by function
- **Linters/Formatters**: Code quality tools in their own category
- **Package Managers**: Package manager configurations (Cargo, UV, Rye, Conda, etc.) centralized

This structure makes the repository:
- **Easier to navigate**: Find any tool's config by category
- **More maintainable**: Clear where to add new configurations
- **Scalable**: Root directory stays clean as you add more tools

## Resources

- [Dotter Documentation](https://github.com/SuperCuber/dotter)
- [Dotter Wiki](https://github.com/SuperCuber/dotter/wiki)
- [Fish Shell Documentation](https://fishshell.com/docs/current/)
