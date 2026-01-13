# mojo-ini 🔥

**INI file parser and writer for Mojo** - Python `configparser` compatible

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Mojo](https://img.shields.io/badge/Mojo-🔥-orange)](https://www.modular.com/mojo)

Parse and write INI configuration files in native Mojo with zero Python dependencies. Compatible with Python's `configparser` module for drop-in replacement in Mojo projects.

## Features

- ✅ **Python `configparser` Compatible** - Drop-in replacement for Python's standard library
- ✅ **Parser & Writer** - Both read and write INI files  
- ✅ **Classic INI Support** - Standard `key = value` syntax with `[sections]`
- ✅ **Extended Features** - Multiline values, inline comments, value interpolation
- ✅ **Multiple Dialects** - configparser (default) and classic INI modes
- ✅ **Comprehensive Tests** - Full test coverage
- ✅ **Zero Dependencies** - Pure Mojo implementation

**Status**: 🚧 **In Development** - v0.1.0 coming soon

## Quick Start

**Parsing INI Files:**

```mojo
from ini.parser import parse

var config = parse("""
[Database]
host = localhost
port = 5432
user = admin

[Server]
debug = true
timeout = 30
""")

# Access values
print(config["Database"]["host"])    # localhost
print(config["Database"]["port"])    # 5432
print(config["Server"]["debug"])     # true
```

**Writing INI Files:**

```mojo
from ini.writer import to_ini

var data = Dict[String, Dict[String, String]]()
data["App"] = Dict[String, String]()
data["App"]["name"] = "MyApp"
data["App"]["version"] = "1.0"

var ini_text = to_ini(data)
print(ini_text)
# Output:
# [App]
# name = MyApp
# version = 1.0
```

See `examples/read_example.mojo` and `examples/write_example.mojo` for complete working examples.

## Installation

### Option 1: Magic Package Manager (Recommended)

```bash
magic add mojo-ini
```

### Option 2: Git Submodule

```bash
git submodule add https://github.com/databooth/mojo-ini vendor/mojo-ini
```

Then in your Mojo code:
```bash
mojo -I vendor/mojo-ini/src your_app.mojo
```

### Option 3: Direct Copy

```bash
cp -r mojo-ini/src/ini your-project/lib/ini
```

## Usage

### Basic Parsing

```mojo
from ini.parser import parse

var config = parse("""
[DEFAULT]
base_url = https://example.com

[API]
endpoint = /api/v1
timeout = 30
""")

print(config["API"]["endpoint"])  # /api/v1
print(config["API"]["timeout"])   # 30
```

### File I/O

> ⚠️ **Coming in v0.1.0** - File I/O convenience functions not yet implemented. Use Mojo's built-in file operations for now:

```mojo
from ini.parser import parse
from ini.writer import to_ini

# Read from file
with open("config.ini", "r") as f:
    var content = f.read()
    var config = parse(content)

# Modify
config["Server"]["port"] = "8080"

# Write back
with open("config.ini", "w") as f:
    f.write(to_ini(config))
```

### Python configparser Compatibility

> ⚠️ **Coming in v0.2.0** - ConfigParser API with type converters planned for future release.

For now, all values are strings. Manual conversion:

```mojo
from ini.parser import parse

var config = parse("...")

# Manual type conversion
var port = int(config["Server"]["port"])                    # Int
var debug = config["Server"]["debug"] == "true"            # Bool
var timeout = float64(config["API"]["timeout"])            # Float64
```

## Supported INI Features

### Classic INI (Default)
- `[section]` headers
- `key = value` pairs
- `# comments` and `; comments`
- Multiline values (indented continuation)
- Inline comments

### Extended (configparser mode)
- `[DEFAULT]` section for shared values
- Value interpolation: `%(var)s` references
- Type conversion helpers (getint, getboolean, etc.)
- Case-insensitive section/key names (optional)

## Python Compatibility

mojo-ini aims for high compatibility with Python's `configparser`:

| Feature | Python configparser | mojo-ini v0.1 |
|---------|-------------------|---------------|
| Basic key=value | ✅ | ✅ |
| [Sections] | ✅ | ✅ |
| [DEFAULT] | ✅ | 🚧 Planned |
| Multiline values | ✅ | ✅ |
| Inline comments | ✅ | ✅ |
| Value interpolation | ✅ | 🚧 Planned |
| Type converters | ✅ | ✅ |
| Case insensitive | ✅ | 🚧 Planned |

## Development

### Setup

```bash
# Install pixi (if not already installed)
curl -fsSL https://pixi.sh/install.sh | bash

# Install dependencies
pixi install

# Verify Mojo version
pixi run mojo-version
```

### Testing

```bash
# Run all tests
pixi run test-all

# Run individual test suites
pixi run test-lexer
pixi run test-parser
pixi run test-writer
pixi run test-configparser

# Build package
pixi run build-package
```

### Benchmarks

```bash
# Benchmark mojo-ini performance
pixi run benchmark-mojo

# Compare with Python configparser
pixi run benchmark-python
```

## Roadmap

See [ROADMAP.md](docs/planning/ROADMAP.md) for detailed development timeline.

### v0.1.0 (Target: Q1 2026)
- ✅ Basic INI parsing (sections, key=value)
- ✅ INI writer
- ✅ Comments support (# and ;)
- ✅ Multiline values
- ✅ Core test suite

### v0.2.0 (Target: Q2 2026)
- 🚧 [DEFAULT] section support
- 🚧 Value interpolation %(var)s
- 🚧 configparser API compatibility
- 🚧 Type converters (getint, getboolean, etc.)

### v0.3.0 (Target: Q3 2026)
- 🚧 Case-insensitive mode
- 🚧 Git config format support
- 🚧 Advanced interpolation

## Documentation

- [CHANGELOG.md](CHANGELOG.md) - Version history and changes
- [docs/planning/](docs/planning/) - Technical documentation and design docs
- [examples/](examples/) - Usage examples

## Related Projects

- [mojo-toml](https://github.com/databooth/mojo-toml) - TOML 1.0 parser/writer for modern configs
- [mojo-dotenv](https://github.com/databooth/mojo-dotenv) - Environment variable management

Together these provide comprehensive configuration file support for Mojo! 🎯

## Contributing

Contributions welcome! Please:
1. Follow existing code style (see mojo-toml for reference)
2. Add tests for new features
3. Update documentation
4. Use Australian English for docs, US spelling for code

## License

MIT License - see [LICENSE](LICENSE) file for details

---

Made with 🔥 by [DataBooth](https://github.com/databooth)
