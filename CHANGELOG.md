# Changelog

All notable changes to mojo-ini will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-01-13

**Status:** ✅ Production Ready

First production release of mojo-ini! A native Mojo INI file parser and writer with Python `configparser` compatibility.

### Added

#### Core Functionality
- **Lexer** (364 LOC): Complete tokenization with 7 token types (EOF, NEWLINE, COMMENT, SECTION, KEY, VALUE, EQUALS)
- **Parser** (171 LOC): Builds `Dict[String, Dict[String, String]]` from tokens
- **Writer** (142 LOC): Serializes Dict structures to INI format
- **Public API** (`__init__.mojo`): Clean imports `from ini import parse, to_ini, parse_file, write_file`

#### INI Features
- Section headers: `[section_name]`
- Key-value pairs with `=` or `:` separators
- Comments: `#` (hash) and `;` (semicolon) styles
- Inline comments after values
- **Multiline values**: Indented continuation lines (Python configparser compatible)
- Empty values and empty sections
- Special characters in values (URLs, paths, emails, Unicode)
- Default section (empty string key) for keys before any `[section]`

#### File I/O
- `parse_file(path)`: Read and parse INI files
- `write_file(path, data)`: Write Dict structures to INI files

#### Testing
- **46 tests** across 5 test suites (100% passing)
- Lexer tests (9 tests): Token generation and position tracking
- Parser tests (10 tests): Structure building, edge cases, errors
- Writer tests (9 tests): Formatting, roundtrip validation
- Fixture tests (7 tests): Real-world INI files (sample, git, mypy, windows, multiline, edge cases)
- Error tests (11 tests): Malformed input, Unicode, stress tests (10K char lines, 100+ sections)

#### Examples
- `examples/read_example.mojo`: Basic parsing demonstration
- `examples/write_example.mojo`: INI generation demonstration  
- `examples/file_io_example.mojo`: File reading/writing with modifications

#### Documentation
- Comprehensive README with Quick Start, usage examples, limitations
- `WARP.md`: Development guidelines and architecture documentation
- Python comparison benchmarks (70-108 µs parse, 8-12 µs write)

### Python configparser Compatibility

✅ **Compatible:**
- Basic key=value syntax
- `[Section]` headers
- `# comments` and `; comments`
- Multiline values (indented continuations)
- Inline comments
- Empty values
- Special characters in values

🚧 **Planned for v0.2.0:**
- `[DEFAULT]` section with value inheritance
- Value interpolation `%(var)s`
- `ConfigParser` class API
- Type converters (`getint`, `getboolean`, `getfloat`)
- Case-insensitive mode

### Known Limitations

**Indented keys NOT supported** (by design, matches Python `configparser`):
- Lines starting with whitespace are treated as multiline value continuations
- Tab-indented keys (Git config style) require removing leading tabs
- Workaround: Keep all keys at column 0, or use TOML/YAML for nested structures

### Technical Details

- **Language**: Pure Mojo (zero Python dependencies at runtime)
- **LOC**: 1,426 total (733 source, 628 tests, 65 examples)
- **Architecture**: Three-stage pipeline (Lexer → Parser → Writer)
- **Error Handling**: Clear error messages with line numbers and context
- **Package Manager**: pixi for reproducible builds
- **Pre-commit**: TOML/YAML/JSON validation, whitespace/EOF checks

---

For detailed development plans, see [docs/planning/ROADMAP.md](docs/planning/ROADMAP.md)
