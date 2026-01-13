# mojo-ini v0.2.0 - Native INI Parser

From the author (@mjboothaus) of [mojo-dotenv](https://github.com/databooth/mojo-dotenv) and [mojo-toml](https://github.com/databooth/mojo-toml) comes **mojo-ini**, a native INI file parser and writer for Mojo with Python `configparser` compatibility and zero dependencies.

## What it does

Parses and writes INI configuration files into native Mojo structures:
- Classic INI format: `[sections]` and `key = value` pairs
- Comments: `#` and `;` styles
- Multiline values (indented continuation)
- Inline comments
- File I/O helpers (`parse_file`, `write_file`)
- Clear error messages with line/column context
- 46 tests ensuring reliability

## Installation

```bash
git clone https://github.com/DataBooth/mojo-ini.git
cd mojo-ini
pixi run test-all
```

Coming soon to the `modular-community` channel.

## Usage

**Parsing:**

```mojo
from ini import parse

fn main() raises:
    var config = parse("""
        [Database]
        host = localhost
        port = 5432
        user = admin
    """)

    print(config["Database"]["host"])  # "localhost"
    print(config["Database"]["port"])  # "5432"
```

**Writing:**

```mojo
from ini import to_ini

fn main() raises:
    var data = Dict[String, Dict[String, String]]()
    data["App"] = Dict[String, String]()
    data["App"]["name"] = "MyApp"
    data["App"]["version"] = "1.0"

    var ini_text = to_ini(data)
    print(ini_text)
    # [App]
    # name = MyApp
    # version = 1.0
```

**File I/O:**

```mojo
from ini import parse_file, write_file

fn main() raises:
    var config = parse_file("config.ini")
    config["Server"]["port"] = "8080"
    write_file("config.ini", config)
```

## What's in v0.2.0

- Complete INI parser and writer (677 LOC)
- Multiline value support (Python configparser compatible)
- File I/O helpers for reading and writing files
- 46 comprehensive tests across 5 test suites
- Performance benchmarks with statistical reporting:
  - Small configs: ~9 μs parse, ~1 μs write
  - Medium configs: ~97 μs parse, ~23 μs write
  - Large configs: ~1038 μs parse, ~237 μs write
  - **7-10x faster than Python** for small configs

See the [CHANGELOG](https://github.com/DataBooth/mojo-ini/blob/main/CHANGELOG.md) for full details.

## Links

- [GitHub Repository](https://github.com/DataBooth/mojo-ini)
- [v0.2.0 Release](https://github.com/DataBooth/mojo-ini/releases/tag/v0.2.0)
- [Documentation](https://github.com/DataBooth/mojo-ini/blob/main/README.md)
- License: MIT

## Python configparser Compatibility

mojo-ini aims for high compatibility with Python's `configparser`:

| Feature | Python | mojo-ini v0.2 |
|---------|--------|---------------|
| Basic key=value | ✅ | ✅ |
| [Sections] | ✅ | ✅ |
| Multiline values | ✅ | ✅ |
| Inline comments | ✅ | ✅ |
| [DEFAULT] section | ✅ | 🚧 Planned v0.3 |
| Value interpolation | ✅ | 🚧 Planned v0.3 |
| Type converters | ✅ | 🚧 Planned v0.3 |

## Roadmap

Planned features for future releases:
- `[DEFAULT]` section with value inheritance
- Value interpolation `%(var)s`
- ConfigParser class API with type converters
- Case-insensitive mode

## Related Projects

- [mojo-toml](https://github.com/databooth/mojo-toml) - TOML 1.0 parser for modern configs
- [mojo-dotenv](https://github.com/databooth/mojo-dotenv) - Environment variable management

Together these provide comprehensive configuration file support for Mojo! 🎯

## Acknowledgements

This project is sponsored by [DataBooth](https://www.databooth.com.au/posts/mojo), building high-performance data and AI services with Mojo.

Feedback and contributions welcome!
