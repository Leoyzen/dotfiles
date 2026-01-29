# Dash Entry Types

Complete reference for Dash docset entry types with semantic meanings and usage examples.

## Core Programming Types

### Classes & Objects
- **Class**: Class definitions
- **Object**: Object instances or general object references
- **Interface**: Interface definitions (TypeScript, Java, C#)
- **Struct**: Structure definitions (C, C++, Rust)
- **Extension**: Extensions to existing types (Swift, Kotlin)
- **Mixin**: Mixin classes providing reusable functionality (Ruby, Dart)

### Functions & Methods
- **Function**: Global functions or standalone functions
- **Method**: Class/instance methods
- **Constructor**: Class constructors
- **Callback**: Callback functions or event handlers
- **Subroutine**: Subroutines (older programming languages)
- **Procedure**: Procedures (SQL, older languages)

### Properties & Data
- **Property**: Class properties
- **Attribute**: Class/instance attributes (Python)
- **Field**: Model fields, structure fields, class members
- **Constant**: Immutable global variables
- **Variable**: Mutable variables
- **Value**: Enumeration members, constant values
- **Parameter**: Function parameters
- **Global**: Global variables or functions

### Types & Definitions
- **Type**: Custom type definitions, typedefs, type aliases
- **Enum**: Enumerations
- **Union**: Union types (TypeScript, Python typing)
- **Trait**: Trait definitions (Rust, Scala)
- **Protocol**: Protocol definitions (Python, Swift, Objective-C)

### Language Features
- **Decorator**: Python decorators or meta-programming constructs
- **Macro**: Macro definitions (C, C++, Lisp, Rust)
- **Annotation**: Annotations or metadata (Java, TypeScript)
- **Operator**: Operators and operator overloading
- **Keyword**: Language keywords and reserved words
- **Literal**: Literal values or constants
- **Statement**: Language statements or expressions

## Advanced Types

### Error Handling
- **Exception**: Exception classes
- **Error**: Error types or error codes

### Object-Oriented
- **Category**: Objective-C categories
- **Delegate**: Delegates (C#)
- **Module**: Software modules or packages
- **Namespace**: Namespaces (C++, C#, XML)
- **Package**: Software packages (Java, Python)

### Framework Specific
- **Framework**: Framework names or namespaces
- **Library**: Library names or external dependencies
- **Component**: UI components (React, Vue, Angular)
- **Directive**: Template directives (Angular, Vue)
- **Filter**: Template filters (Jinja2, Django)
- **Plugin**: Plugins or extensions
- **Service**: Services (Angular, dependency injection)

## Documentation & Navigation

### Pages & Sections
- **Guide**: Documentation pages, tutorials, or major landing pages
- **Section**: Page subsections (H2/H3). Note: Usually excluded from global search
- **Entry**: General documentation entries (fallback type)
- **Sample**: Code samples or examples

### Special Content
- **Diagram**: Diagrams, charts, or visual documentation
- **Table**: Tables (used when indexing table content)
- **Resource**: External resources or file references
- **File**: File references or documentation files

## Specialized Types

### Web & UI
- **Style**: CSS styles or classes
- **Template**: HTML/UI templates
- **Element**: HTML/DOM elements

### Configuration & Build
- **Setting**: Configuration options or settings
- **Option**: Command-line options or configuration keys
- **Define**: Preprocessor definitions (C, C++)
- **Command**: Command-line commands or CLI tools
- **Instruction**: Assembly instructions or low-level commands

### Binding & Integration
- **Binding**: Language bindings or bindings to external libraries
- **Hook**: Hooks (git hooks, React hooks, lifecycle hooks)
- **Provider**: Providers (dependency injection, state management)
- **Provisioner**: Provisioning scripts or tools (infrastructure)
- **Instance**: Instance variables or specific instances

### Utilities
- **Builtin**: Built-in functions or types
- **Environment**: Environment variables
- **Shortcut**: Keyboard shortcuts or quick access commands
- **Tag**: Tags or markers (HTML, git tags)
- **Query**: Database queries or search queries
- **Record**: Database records or data records
- **Test**: Test functions or test cases
- **Word**: Words in documentation (rarely used)

### Other
- **Notation**: Mathematical notation or special notation
- **Request**: API request types or HTTP request formats
- **Event**: Events (DOM events, system events)

## Entry Type Selection Guide

### For Python Documentation
- Classes → `Class`
- Functions → `Function`
- Methods → `Method`
- Properties → `Property`
- Attributes → `Attribute`
- Decorators → `Decorator`
- Exceptions → `Exception`
- Modules → `Module`
- Data model fields → `Field`
- Type aliases → `Type`

### For JavaScript/TypeScript
- Classes → `Class`
- Functions → `Function`
- Interfaces → `Interface`
- Types → `Type`
- Enums → `Enum`
- Components (React/Vue) → `Component`
- Props/parameters → `Parameter`
- Decorators → `Decorator`

### For Java Documentation
- Classes → `Class`
- Interfaces → `Interface`
- Enums → `Enum`
- Methods → `Method`
- Fields → `Field`
- Annotations → `Annotation`

### For Rust Documentation
- Structs → `Struct`
- Enums → `Enum`
- Traits → `Trait`
- Functions → `Function`
- Methods → `Method`
- Macros → `Macro`

### For Configuration Documentation
- Configuration keys → `Setting`
- Options → `Option`
- Environment variables → `Environment`

### For API Documentation
- Endpoints → `Function` or `Command`
- Request types → `Request`
- Response types → `Type`
- Status codes → `Constant`

### For General Web Docs
- Main pages → `Guide`
- Subsections → `Section`
- Code examples → `Sample`
- Terms → `Entry`
