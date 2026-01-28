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


fn parse(content: String) raises -> Dict[String, Dict[String, String]]:
    """Parse INI string into nested dictionary.

    Args:
        content: INI formatted string

    Returns:
        Dict mapping section names to key-value pairs

    Raises:
        Error: If INI syntax is invalid

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
    """
    return _parse(content)


fn to_ini(data: Dict[String, Dict[String, String]]) raises -> String:
    """Convert nested dictionary to INI format string.

    Args:
        data: Dict mapping section names to key-value pairs

    Returns:
        INI formatted string

    Example:
        ```mojo
        from ini import to_ini

        var data = Dict[String, Dict[String, String]]()
        data["App"] = Dict[String, String]()
        data["App"]["name"] = "MyApp"

        var ini_text = to_ini(data)
        print(ini_text)  # [App]\nname = MyApp\n
        ```
    """
    return _to_ini(data)


fn parse_file(path: String) raises -> Dict[String, Dict[String, String]]:
    """Parse INI file into nested dictionary.

    Args:
        path: Path to INI file

    Returns:
        Dict mapping section names to key-value pairs

    Raises:
        Error: If file cannot be read or INI syntax is invalid

    Example:
        ```mojo
        from ini import parse_file

        var config = parse_file("config.ini")
        print(config["Server"]["port"])
        ```
    """
    with open(path, "r") as f:
        var content = f.read()
        return _parse(content)


fn write_file(path: String, data: Dict[String, Dict[String, String]]) raises:
    """Write nested dictionary to INI file.

    Args:
        path: Path to output INI file
        data: Dict mapping section names to key-value pairs

    Raises:
        Error: If file cannot be written

    Example:
        ```mojo
        from ini import write_file

        var data = Dict[String, Dict[String, String]]()
        data["App"] = Dict[String, String]()
        data["App"]["version"] = "1.0"

        write_file("output.ini", data)
        ```
    """
    var ini_text = _to_ini(data)
    with open(path, "w") as f:
        f.write(ini_text)
