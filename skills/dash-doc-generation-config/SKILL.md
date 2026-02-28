---
name: dash-doc-generation-config
description: Generates a complete Dash Docset configuration for a given website URL. This includes website filters, download patterns, indexing JavaScript (supporting hierarchical naming and semantic entry types), and custom CSS for a clean native-app feel. Use when a user asks to "generate dash config", "build dash docset", or provides a documentation URL to be converted for Dash.
disable-model-invocation: true
---

# Dash Docset Generation Config

This skill guides the generation of professional Dash docset configurations. It focuses on clean indexing, hierarchical naming, and a native app UI.

## Workflow

1.  **Analyze Website Structure** (THOROUGH):
    *   **Main page**: Fetch and analyze the homepage structure
    *   **Navigation sections**: Identify major sections from navigation (API, Guides, Configuration, etc.)
    *   **Sample pages per section**: Fetch at least one representative page from each major section
        *   Example sections to check: API reference, Guides, Configuration, Tutorials, Examples
    *   **Document framework**: Identify framework (MkDocs, Sphinx, Docusaurus, etc.) and its selector patterns
    *   **Content variations**: Note differences in structure across section types (API pages vs Guide pages)

2.  **Define Scope**:
    *   **Website URL**: The base URL.
    *   **Download Patterns**: Patterns to include (e.g., `domain.com/docs/*`).
    *   **Ignore Patterns**: Noise pages (e.g., `/contact`, `/search`).

3.  **Construct Indexing Script** (COMPREHENSIVE):
    *   **Handle all page types** discovered in step 1:
        *   Guide/tutorial pages (often have different structure)
        *   API reference pages (class/function/method structures)
        *   Configuration pages (setting/option definitions)
        *   Examples pages (code samples)
    *   Implement **Hierarchical Guide Naming**: Use breadcrumbs or navigation state to build names like `Parent / Child / Page`.
    *   Implement **API Naming**: Use `{Class}.{Name}` format, stripping unnecessary top-level package names.
    *   Map **Entry Types**: Refer to [entry_types.md](references/entry_types.md) for semantic mapping (e.g., `Field`, `Decorator`, `Setting`, `Component`, `Service`).

4.  **Draft Custom CSS**:
    *   Hide all web-specific UI elements (Header, Footer, Sidebars).
    *   Ensure content expands to fill the window.
    *   Optimize API readability.

## Naming Conventions

### Guides
Always try to use folder-like hierarchy in Guide names:
```javascript
// Example: "Concepts / Models / BaseModel"
dashDoc.addEntry({name: "Folder / Subfolder / Page", type: "Guide"});
```

### API Entries
Use `{Class}.{Name}`. Avoid package-level prefixes unless essential for clarity.
*   Correct: `BaseModel.model_dump`
*   Incorrect: `pydantic.main.BaseModel.model_dump`

## Selection Guide for Entry Types

See [entry_types.md](references/entry_types.md) for full list.
- Use `Field` for data model attributes.
- Use `Decorator` for validation/logic hooks.
- Use `Setting` for config dicts.
- Use `Section` for H2/H3 headers (excluded from global search).

## Common Frameworks

Refer to [selectors.md](references/selectors.md) for framework-specific CSS selectors.

## Output Format

Generate two files in the **current working directory**:

### 1. Markdown Configuration
Contains the 5 required sections (Website URL, Download Patterns, Ignore Patterns, Indexing Script, Custom CSS). This is for documentation and manual review.

### 2. DocsetConfig File
A complete `.docsetconfig` XML plist file with all Dash-specific configurations.

**File naming**: `{docset_name}.docsetconfig`

Example: If the docset name is "pydantic-ai", the file should be named `pydantic-ai.docsetconfig`

Use [docsetconfig_template.xml](references/docsetconfig_template.xml) as a reference template.

The `.docsetconfig` file structure:
- **docsetName**: Display name (no spaces, e.g., "pydantic-ai")
- **websiteURL**: Base documentation URL
- **allowFilters**: Download patterns (e.g., `domain.com/docs/*`)
- **denyFilters**: Pages to exclude (e.g., `*/search/*`)
- **docsetKeyword**: Search keyword (e.g., "pdai" for Pydantic AI)
- **cssToInject**: Custom CSS for clean Dash UI
- **javaScriptUsedToIndex**: Hierarchical indexing script with semantic types

### Post-Generation

After generating both files, ask the user:
> "Would you like me to generate the docset from this configuration and import it into Dash?"

## Docset Generation

The `.docsetconfig` file can be used with the DocsetGenerator tool to generate and import Dash docsets.

### Installing DocsetGenerator

**macOS (Homebrew):**
```bash
brew install docsetgenerator
```

**Manual download:**
1. Download: https://kapeli.com/feeds/zzz/DocsetGenerator.tgz
2. Unarchive and run from extracted directory

### Generating the Docset

Once DocsetGenerator is installed:

```bash
# From the directory containing your .docsetconfig file:
DocsetGenerator "your-docset-name.docsetconfig"
```

This will:
1. Download and index all documentation pages
2. Apply custom CSS and indexing JavaScript
3. Generate a complete Dash docset
4. Open Dash and import the new docset automatically

The generated docset includes searchable entries with hierarchical navigation, semantic type mapping (Class, Method, Field, etc.), and a clean native-app UI.
