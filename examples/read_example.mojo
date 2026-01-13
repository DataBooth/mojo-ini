"""
Read Example - Parsing INI Configuration Files

This example demonstrates how to parse INI files and access configuration values.
Run with: mojo -I src examples/read_example.mojo
"""

from ini.parser import parse


fn main() raises:
    # Parse INI configuration string
    var config = parse("""
[Database]
host = localhost
port = 5432
user = admin

[Server]
debug = true
timeout = 30
""")

    # Access values from different sections
    print("Database Configuration:")
    print("  Host:", config["Database"]["host"])
    print("  Port:", config["Database"]["port"])
    print("  User:", config["Database"]["user"])
    print()

    print("Server Configuration:")
    print("  Debug:", config["Server"]["debug"])
    print("  Timeout:", config["Server"]["timeout"])
