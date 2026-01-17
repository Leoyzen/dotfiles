# Dotter Syntax Cheat Sheet

## Configuration (global.toml)

### Package Definition
```toml
[package_name]
depends = ["dep1"]

[package_name.files]
# Simple
"vimrc" = "~/.vimrc"
# Complex
"config" = { target = "~/.config/app", type = "template" }

[package_name.variables]
theme = "dark"
```

### File Types
- **Automatic**: Default. Templates if `{{` found, else symlink.
- **Symbolic**: Symlink (fast, no processing).
- **Template**: Handlebars processing.

## Handlebars Templating

### Variables
- `{{variable}}` - Insert variable
- `{{dotter.os}}` - OS (linux/macos/windows)
- `{{dotter.hostname}}` - Hostname

### Conditionals
```handlebars
{{#if use_vim}}
  set editor=vim
{{else}}
  set editor=nano
{{/if}}

{{#if (eq dotter.os "macos")}} ... {{/if}}
```

### Loops
```handlebars
{{#each plugins}}
  Plugin '{{this}}'
{{/each}}
```

### Helpers
- `{{default var "value"}}` - Default value
- `{{#withDefault var}} ... {{/withDefault}}`
- Logic: `eq`, `neq`, `gt`, `lt`, `and`, `or`, `not`
