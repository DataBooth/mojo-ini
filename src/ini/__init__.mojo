"""mojo-ini: INI file parser and writer for Mojo.

Python `configparser` compatible INI file handling with zero dependencies.

Example:
    ```mojo
    from ini import parse, to_ini

    var config = parse('''
    [Database]
    host = localhost
    port = 5432
    ''')

    print(config["Database"]["host"])  # "localhost"
    ```

Architecture:
    - Lexer: Tokenises INI text (comments, sections, key=value)
    - Parser: Builds Dict[String, Dict[String, String]] from tokens
    - Writer: Serialises Dict structure to INI format

Status: v0.2.2 - Production Ready
"""

# Public API - re-export from submodules
from .parser import parse as _parse
from .writer import to_ini as _to_ini


def parse(content: String) raises -> Dict[String, Dict[String, String]]:
    """Parse INI string into nested dictionary.

    The ``content`` parameter is an INI formatted string.

    Returns a dictionary mapping section names to key-value pairs.

    Raises an ``Error`` if INI syntax is invalid.

    Example:
        ```mojo
        from ini import parse

        var config = parse('''
        [Database]
        host = localhost
        port = 5432
        ''')

        print(config["Database"]["host"])  # "localhost"
        ```
        Example usage.
    """
    return _parse(content)


def to_ini(data: Dict[String, Dict[String, String]]) raises -> String:
    """Convert nested dictionary to INI format string.

    The ``data`` argument is a dict mapping section names to key-value pairs.

    Returns an INI formatted string.

    Example:
        ```mojo
        from ini import to_ini

        var data = Dict[String, Dict[String, String]]()
        data["App"] = Dict[String, String]()
        data["App"]["name"] = "MyApp"

        var ini_text = to_ini(data)
        print(ini_text)  # [App]\nname = MyApp\n
        ```
        Example usage.
    """
    return _to_ini(data)


def parse_file(path: String) raises -> Dict[String, Dict[String, String]]:
    """Parse INI file into nested dictionary.

    The ``path`` parameter is the path to the INI file.

    Returns a dict mapping section names to key-value pairs.

    Raises an ``Error`` if the file cannot be read or INI syntax is invalid.

    Example:
        ```mojo
        from ini import parse_file

        var config = parse_file("config.ini")
        print(config["Server"]["port"])
        ```
        Example usage.
    """
    with open(path, "r") as f:
        var content = f.read()
        return _parse(content)


def write_file(path: String, data: Dict[String, Dict[String, String]]) raises:
    """Write nested dictionary to INI file.

    The ``path`` parameter is the path to the output INI file.
    The ``data`` argument is a dict mapping section names to key-value pairs.

    Raises an ``Error`` if the file cannot be written.

    Example:
        ```mojo
        from ini import write_file

        var data = Dict[String, Dict[String, String]]()
        data["App"] = Dict[String, String]()
        data["App"]["version"] = "1.0"

        write_file("output.ini", data)
        ```
        Example usage.
    """
    var ini_text = _to_ini(data)
    with open(path, "w") as f:
        f.write(ini_text)
