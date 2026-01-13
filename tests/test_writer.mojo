"""Test suite for INI writer.

Tests serialisation of Dict structures to INI format:
- Section headers
- Key-value pairs  
- Default section (no header)
- Multiple sections
- Roundtrip (parse → write → parse)
"""

from testing import assert_equal, assert_true, TestSuite
from ini.parser import parse
from ini.writer import to_ini
from collections import Dict


fn test_empty_dict() raises:
    """Test writing empty dictionary."""
    var data = Dict[String, Dict[String, String]]()
    data[""] = Dict[String, String]()  # Empty default section
    
    var ini_text = to_ini(data)
    assert_equal(ini_text, "", "Empty dict should produce empty string")


fn test_single_section_single_key() raises:
    """Test writing single section with one key."""
    var data = Dict[String, Dict[String, String]]()
    data["Database"] = Dict[String, String]()
    data["Database"]["host"] = "localhost"
    
    var ini_text = to_ini(data)
    
    assert_true("[Database]" in ini_text, "Should have section header")
    assert_true("host = localhost" in ini_text, "Should have key-value pair")


fn test_single_section_multiple_keys() raises:
    """Test writing section with multiple keys."""
    var data = Dict[String, Dict[String, String]]()
    data["Server"] = Dict[String, String]()
    data["Server"]["host"] = "0.0.0.0"
    data["Server"]["port"] = "8080"
    data["Server"]["debug"] = "true"
    
    var ini_text = to_ini(data)
    
    assert_true("[Server]" in ini_text, "Should have section header")
    assert_true("host = 0.0.0.0" in ini_text, "Should have host")
    assert_true("port = 8080" in ini_text, "Should have port")
    assert_true("debug = true" in ini_text, "Should have debug")


fn test_multiple_sections() raises:
    """Test writing multiple sections."""
    var data = Dict[String, Dict[String, String]]()
    data["Database"] = Dict[String, String]()
    data["Database"]["host"] = "localhost"
    data["Server"] = Dict[String, String]()
    data["Server"]["port"] = "8080"
    
    var ini_text = to_ini(data)
    
    assert_true("[Database]" in ini_text, "Should have Database section")
    assert_true("[Server]" in ini_text, "Should have Server section")
    assert_true("host = localhost" in ini_text, "Should have Database host")
    assert_true("port = 8080" in ini_text, "Should have Server port")


fn test_default_section() raises:
    """Test writing keys without section header (default section)."""
    var data = Dict[String, Dict[String, String]]()
    data[""] = Dict[String, String]()  # Default section
    data[""]["key1"] = "value1"
    data[""]["key2"] = "value2"
    
    var ini_text = to_ini(data)
    
    # Default section should NOT have a header
    assert_true("[" not in ini_text, "Should not have section headers")
    assert_true("key1 = value1" in ini_text, "Should have key1")
    assert_true("key2 = value2" in ini_text, "Should have key2")


fn test_default_and_named_sections() raises:
    """Test writing both default and named sections."""
    var data = Dict[String, Dict[String, String]]()
    data[""] = Dict[String, String]()
    data[""]["global_key"] = "global_value"
    data["Section"] = Dict[String, String]()
    data["Section"]["key"] = "value"
    
    var ini_text = to_ini(data)
    
    # Default section keys come first, no header
    assert_true("global_key = global_value" in ini_text, "Should have global key")
    # Then named section with header
    assert_true("[Section]" in ini_text, "Should have section header")
    assert_true("key = value" in ini_text, "Should have section key")


fn test_roundtrip_simple() raises:
    """Test parse → write → parse produces same result."""
    var original_ini = """[Database]
host = localhost
port = 5432

[Server]
debug = true
timeout = 30"""
    
    # Parse original
    var data1 = parse(original_ini)
    
    # Write to INI
    var written_ini = to_ini(data1)
    
    # Parse written INI
    var data2 = parse(written_ini)
    
    # Should have same sections and values
    assert_equal(data1["Database"]["host"], data2["Database"]["host"])
    assert_equal(data1["Database"]["port"], data2["Database"]["port"])
    assert_equal(data1["Server"]["debug"], data2["Server"]["debug"])
    assert_equal(data1["Server"]["timeout"], data2["Server"]["timeout"])


fn test_roundtrip_with_special_chars() raises:
    """Test roundtrip with special characters in values."""
    var data1 = Dict[String, Dict[String, String]]()
    data1["Test"] = Dict[String, String]()
    data1["Test"]["email"] = "user@example.com"
    data1["Test"]["url"] = "https://example.com/path?query=1"
    data1["Test"]["path"] = "/path/with spaces/file"
    
    # Write and parse back
    var ini_text = to_ini(data1)
    var data2 = parse(ini_text)
    
    # Should preserve special characters
    assert_equal(data1["Test"]["email"], data2["Test"]["email"])
    assert_equal(data1["Test"]["url"], data2["Test"]["url"])
    assert_equal(data1["Test"]["path"], data2["Test"]["path"])


fn test_empty_values() raises:
    """Test writing empty string values."""
    var data = Dict[String, Dict[String, String]]()
    data["Test"] = Dict[String, String]()
    data["Test"]["empty_key"] = ""
    data["Test"]["normal_key"] = "value"
    
    var ini_text = to_ini(data)
    
    assert_true("empty_key = " in ini_text, "Should have empty value")
    assert_true("normal_key = value" in ini_text, "Should have normal value")


fn main() raises:
    """Run all writer tests using TestSuite."""
    TestSuite.discover_tests[__functions_in_module()]().run()
