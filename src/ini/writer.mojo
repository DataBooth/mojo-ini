"""Writer for INI files.

# Why: Purpose of the Writer
The writer is the serialisation component of mojo-ini. It converts structured
data (nested dictionaries) back into valid INI format strings.

Example transformation:
    Input: {"Database": {"host": "localhost", "port": "5432"}}
    Output: [Database]\\nhost = localhost\\nport = 5432\\n

# What: Responsibilities
- Convert Dict[String, Dict[String, String]] structures into INI strings
- Generate section headers [name]
- Format key-value pairs with proper spacing
- Produce human-readable, valid INI output

# How: Writer Design
The writer uses a buffer-based approach:
1. Handle default section (empty string key) if present
2. Write root key-value pairs (no section header)
3. Write each named section with [section] header
4. Format each key = value pair
5. Return final INI string

This keeps serialisation simple and predictable.
"""

from collections import Dict


struct Writer:
    """INI writer for serialising Dict structures to INI format.

    The writer builds INI output incrementally in a string buffer,
    handling proper formatting and structure.
    """

    var buffer: String

    fn __init__(out self):
        """Initialise writer with empty buffer."""
        self.buffer = ""

    fn write_key_value(mut self, key: String, value: String):
        """Write a key-value pair to the buffer.

        Args:
            key: Key name.
            value: Value string.
        """
        self.buffer += key + " = " + value + "\n"

    fn write_section(mut self, section_name: String):
        """Write a section header to the buffer.

        Args:
            section_name: Section name (without brackets).
        """
        self.buffer += "[" + section_name + "]\n"

    fn write(mut self, data: Dict[String, Dict[String, String]]) raises -> String:
        """Write Dict structure to INI format.

        Args:
            data: Nested dictionary where top-level keys are section names
                  and values are dictionaries of key-value pairs.

        Returns:
            INI formatted string.

        Example:
            ```mojo
            var data = Dict[String, Dict[String, String]]()
            data["Server"] = Dict[String, String]()
            data["Server"]["host"] = "localhost"
            data["Server"]["port"] = "8080"

            var writer = Writer()
            var ini_text = writer.write(data)
            # Output:
            # [Server]
            # host = localhost
            # port = 8080
            ```
        """
        # First, handle default section (empty string key) for root keys
        if "" in data:
            for entry in data[""].items():
                self.write_key_value(entry.key, entry.value)

            # Add blank line after default section if there are other sections
            if len(data) > 1:
                self.buffer += "\n"

        # Write each named section
        var first_section = True
        for section_entry in data.items():
            # Skip default section (already written)
            if section_entry.key == "":
                continue

            # Add blank line between sections (but not before first section)
            if not first_section:
                self.buffer += "\n"
            first_section = False

            # Write section header
            self.write_section(section_entry.key)

            # Write key-value pairs in this section
            for kv_entry in section_entry.value.items():
                self.write_key_value(kv_entry.key, kv_entry.value)

        return self.buffer


fn to_ini(data: Dict[String, Dict[String, String]]) raises -> String:
    """Convert Dict structure to INI format string.

    Convenience function that handles writing in one step.

    Args:
        data: Nested dictionary mapping section names to key-value pairs.

    Returns:
        INI formatted string.

    Example:
        ```mojo
        var data = Dict[String, Dict[String, String]]()
        data["Database"] = Dict[String, String]()
        data["Database"]["host"] = "localhost"

        var ini_text = to_ini(data)
        print(ini_text)
        # Output:
        # [Database]
        # host = localhost
        ```
    """
    var writer = Writer()
    return writer.write(data)
