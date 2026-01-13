"""
File I/O Example - Reading and Writing INI Files

This example demonstrates the parse_file() and write_file() helper functions.
Run with: mojo -I src examples/file_io_example.mojo
"""

from ini import parse_file, write_file


fn main() raises:
    # Read an existing INI file
    print("Reading fixtures/sample.ini...")
    var config = parse_file("fixtures/sample.ini")

    print("Database host:", config["Database"]["host"])
    print("Server port:", config["Server"]["port"])
    print()

    # Modify configuration
    config["Database"]["host"] = "192.168.1.100"
    config["Server"]["port"] = "9090"

    # Add new section
    config["Cache"] = Dict[String, String]()
    config["Cache"]["enabled"] = "true"
    config["Cache"]["ttl"] = "3600"

    # Write to new file
    print("Writing modified config to /tmp/modified_config.ini...")
    write_file("/tmp/modified_config.ini", config)
    print("Done! Check /tmp/modified_config.ini")
