# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

mojo-ini is a native INI file parser and writer for Mojo with Python `configparser` compatibility. The project aims to provide drop-in replacement functionality for Python's standard library configparser module, enabling seamless INI file handling in Mojo projects.

**Status:** v0.2.0 - Production Ready (core implementation complete, comprehensive testing, performance benchmarking)

## Essential Commands

### Testing
```bash
# Run all tests (when implemented)
pixi run test-all

# Run individual test suites
pixi run test-lexer          # Tokenisation tests
pixi run test-parser         # Parsing tests
pixi run test-writer         # Writer tests
pixi run test-configparser   # Python compatibility tests
```

### Development
```bash
# Check Mojo version
pixi run mojo-version

# Run examples
pixi run example-read        # Basic parsing demonstration
pixi run example-write       # INI generation demonstration
pixi run example-file-io     # File reading/writing with modifications

# Build package
pixi run build-package       # Creates dist/ini.mojopkg

# Clean build artifacts
pixi run clean
```

### Running Individual Files
```bash
# Test files
mojo -I src tests/test_lexer.mojo

# Examples
mojo -I src examples/read_example.mojo
```

**Important:** Always use `-I src` flag when running Mojo files to include the source directory.

## Architecture

### Design Philosophy

mojo-ini follows the proven architecture from mojo-toml but simplified for INI's simpler format:

**Three-Component Architecture:**

1. **Lexer (src/ini/lexer.mojo)** - Tokenisation
   - Converts raw INI text into token stream
   - Handles comments (# and ;), section headers, key=value pairs
   - Tracks line/column positions for error messages
   - Key types: `Lexer`, `Token`, `TokenKind`, `Position`

2. **Parser (src/ini/parser.mojo)** - Structure Building
   - Consumes token stream and builds Dict[String, Dict[String, String]] structure
   - Implements INI syntax rules (sections, multiline values, etc.)
   - Detects duplicate keys within sections
   - Key types: `Parser`, `IniConfig` (or Dict-based)

3. **Writer (src/ini/writer.mojo)** - Serialisation
   - Converts Dict[String, Dict[String, String]] to INI string
   - Handles comment preservation, multiline formatting
   - Key types: `Writer`, public function `to_ini()`

### Key Differences from TOML

**Simpler:** INI is untyped (everything is strings), so no need for variant types like `TomlValue`
**Flatter:** No nested tables (just [section] headers), simpler parser state machine
**More Permissive:** Looser syntax rules, more forgiving parsing

### Type System

Unlike mojo-toml's `TomlValue` variant, mojo-ini uses simpler structure:
```mojo
Dict[String, Dict[String, String]]
# Outer Dict: section name → section content
# Inner Dict: key → value (all strings)
```

For configparser compatibility (v0.3.0+), we'll add:
```mojo
struct ConfigParser:
    var _data: Dict[String, Dict[String, String]]
    
    fn getint(self, section: String, key: String) -> Int: ...
    fn getboolean(self, section: String, key: String) -> Bool: ...
    fn getfloat(self, section: String, key: String) -> Float64: ...
```

## Python configparser Compatibility

### Target Compatibility Matrix

| Feature | Python | v0.2 | v0.3 | v0.4 |
|---------|--------|------|------|------|
| Basic key=value | ✅ | ✅ | ✅ | ✅ |
| [Sections] | ✅ | ✅ | ✅ | ✅ |
| [DEFAULT] section | ✅ | ❌ | ✅ | ✅ |
| Multiline values | ✅ | ✅ | ✅ | ✅ |
| Inline comments | ✅ | ✅ | ✅ | ✅ |
| Value interpolation %(var)s | ✅ | ❌ | ✅ | ✅ |
| Type converters (getint, etc.) | ✅ | ❌ | ✅ | ✅ |
| Case insensitive | ✅ | ❌ | ❌ | ✅ |

### Reference Implementation

When implementing features, cross-reference with:
- Python `configparser` module documentation
- Python `configparser` source code (Python stdlib)
- Test against Python behavior for edge cases

## Development Roadmap

### v0.2.0 - Core Functionality (Released 2026-01-13) ✅
- [x] Project structure and tooling
- [x] Basic lexer (tokens: SECTION, KEY, VALUE, COMMENT)
- [x] Basic parser (sections + key=value)
- [x] Basic writer (format INI output)
- [x] Multiline value support
- [x] Comment handling (# and ;)
- [x] Comprehensive test suite (46 tests)
- [x] Examples (read, write, file I/O)
- [x] Performance benchmarking with statistical reporting
- [x] File I/O helpers (parse_file, write_file)

### v0.3.0 - configparser Compatibility (Q2 2026)
- [ ] [DEFAULT] section support
- [ ] Value interpolation %(var)s
- [ ] ConfigParser struct with Python-like API
- [ ] Type converters (getint, getboolean, getfloat)
- [ ] Extended test suite (~60 tests)

### v0.4.0 - Advanced Features (Q3 2026)
- [ ] Case-insensitive mode
- [ ] Git config format (subsections)
- [ ] Advanced interpolation
- [ ] Performance optimisations

## Testing Strategy

Tests organised by feature:
- `test_lexer.mojo` - Tokenisation (comments, sections, key=value)
- `test_parser.mojo` - Structure building (sections, multiline, errors)
- `test_writer.mojo` - Serialisation (formatting, escaping)
- `test_configparser_compat.mojo` - Python compatibility (v0.3.0+)

When adding tests:
- Choose the correct test file based on feature
- Keep tests focused on single behaviour
- Use descriptive test names
- Update test count in documentation

## Current Limitations

### Not Yet Implemented
- ConfigParser API (v0.3.0)
- [DEFAULT] section (v0.3.0)
- Value interpolation (v0.3.0)
- Type converters (v0.3.0)
- Case insensitive mode (v0.4.0)

## Contributing Guidelines

### Code Style
- Use Australian English in documentation/comments
- Use US spelling for variable/function names (Mojo convention)
- Document "Why/What/How" in module docstrings
- Keep functions focused and short
- **Reference mojo-toml for patterns** - this project follows similar architecture

### Development Workflow
1. Write test first in appropriate test_*.mojo file
2. Run specific test suite during development: `pixi run test-<feature>`
3. Implement feature in lexer.mojo, parser.mojo, or writer.mojo
4. Validate with full test suite: `pixi run test-all`
5. Update CHANGELOG.md following existing format

### Error Messages
- Always include line/column context from Position
- Format: "Error at line X, column Y: <message>"
- Be specific about what was expected vs what was found

## Dependencies

- **Mojo**: Language runtime (via pixi)
- **Python**: Test runner and benchmarks only
- **pre-commit**: Code quality checks

The library has zero Python dependencies at runtime - pure Mojo implementation.

## Project Structure

```
src/ini/
  __init__.mojo    # Public API: parse(), to_ini(), ConfigParser (v0.2+)
  lexer.mojo       # Token stream generation
  parser.mojo      # Structure building from tokens
  writer.mojo      # INI serialisation

tests/
  test_lexer.mojo        # Tokenisation tests
  test_parser.mojo       # Parsing tests
  test_writer.mojo       # Writer tests
  test_configparser_compat.mojo  # Python compatibility (v0.2+)

examples/
  quickstart.mojo  # README example
  simple.mojo      # Comprehensive API usage

fixtures/          # Sample INI files for testing
docs/planning/     # Design documents and plans
benchmarks/        # Performance comparison with Python
```

## Installation Methods

When helping users integrate this library:

1. **Magic package** (future):
   ```bash
   magic add mojo-ini
   ```

2. **Git submodule** (recommended for projects):
   ```bash
   git submodule add https://github.com/databooth/mojo-ini vendor/mojo-ini
   mojo -I vendor/mojo-ini/src your_app.mojo
   ```

3. **Direct copy** (simplest):
   ```bash
   cp -r mojo-ini/src/ini your-project/lib/ini
   mojo -I your-project/lib your_app.mojo
   ```

## Relationship to mojo-toml

mojo-ini reuses architectural patterns from mojo-toml:
- ✅ Three-component design (lexer/parser/writer)
- ✅ Position tracking for errors
- ✅ Test organisation strategy
- ✅ Documentation approach
- ✅ Build/release process

**Key difference:** INI is simpler (no types, no nesting), so implementation is smaller and faster to develop.

## Version Information

Current version: v0.1.0-dev (January 2026)
- Project structure complete
- Core implementation in progress
- See CHANGELOG.md for version history
