"""
Write Example - Creating INI Configuration Files

This example demonstrates how to build configuration data and write it to INI format.
Run with: mojo -I src examples/write_example.mojo
"""

from ini import to_ini


fn main() raises:
    # Create configuration data structure
    var data = Dict[String, Dict[String, String]]()

    # Add App section
    data["App"] = Dict[String, String]()
    data["App"]["name"] = "MyApp"
    data["App"]["version"] = "1.0"
    data["App"]["author"] = "DataBooth"

    # Add Settings section
    data["Settings"] = Dict[String, String]()
    data["Settings"]["theme"] = "dark"
    data["Settings"]["language"] = "en"
    data["Settings"]["auto_save"] = "true"

    # Convert to INI format
    var ini_text = to_ini(data)

    print("Generated INI Configuration:")
    print("=" * 40)
    print(ini_text)
