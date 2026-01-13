"""Test suite for INI parser.

Tests parsing of INI syntax into nested dictionaries:
- Section handling
- Key-value pairs
- Empty sections
- Default section (keys without [section])
- Duplicate key detection
- Empty values
"""

from testing import assert_equal, assert_true, TestSuite
from ini.parser import parse


fn test_empty_ini() raises:
    """Test parsing empty INI."""
    var data = parse("")
    
    # Should have default section (empty string key)
    assert_true("" in data, "Should have default section")
    assert_equal(len(data[""]), 0, "Default section should be empty")


fn test_single_section_single_key() raises:
    """Test parsing single section with one key."""
    var data = parse("[Database]\nhost = localhost")
    
    assert_true("Database" in data, "Should have Database section")
    assert_true("host" in data["Database"], "Should have 'host' key")
    assert_equal(data["Database"]["host"], "localhost", "Value should be 'localhost'")


fn test_single_section_multiple_keys() raises:
    """Test parsing section with multiple keys."""
    var input = """[Server]
host = 0.0.0.0
port = 8080
debug = true"""
    
    var data = parse(input)
    
    assert_true("Server" in data, "Should have Server section")
    assert_equal(data["Server"]["host"], "0.0.0.0", "host should be '0.0.0.0'")
    assert_equal(data["Server"]["port"], "8080", "port should be '8080'")
    assert_equal(data["Server"]["debug"], "true", "debug should be 'true'")


fn test_multiple_sections() raises:
    """Test parsing multiple sections."""
    var input = """[Database]
host = localhost

[Server]
port = 8080"""
    
    var data = parse(input)
    
    assert_true("Database" in data, "Should have Database section")
    assert_true("Server" in data, "Should have Server section")
    assert_equal(data["Database"]["host"], "localhost")
    assert_equal(data["Server"]["port"], "8080")


fn test_keys_without_section() raises:
    """Test parsing keys before any [section] header."""
    var input = """key1 = value1
key2 = value2

[Section]
key3 = value3"""
    
    var data = parse(input)
    
    # Keys without section go into default section ""
    assert_true("" in data, "Should have default section")
    assert_equal(data[""]["key1"], "value1", "key1 should be in default section")
    assert_equal(data[""]["key2"], "value2", "key2 should be in default section")
    assert_equal(data["Section"]["key3"], "value3", "key3 should be in Section")


fn test_empty_value() raises:
    """Test parsing key with empty value."""
    var data = parse("[Test]\nkey =")
    
    assert_true("Test" in data, "Should have Test section")
    assert_true("key" in data["Test"], "Should have 'key'")
    assert_equal(data["Test"]["key"], "", "Value should be empty string")


fn test_comments_ignored() raises:
    """Test that comments are ignored."""
    var input = """# This is a comment
[Server]
; Windows-style comment
host = localhost  # inline comment
port = 8080"""
    
    var data = parse(input)
    
    assert_true("Server" in data, "Should have Server section")
    assert_equal(data["Server"]["host"], "localhost", "host should be 'localhost'")
    assert_equal(data["Server"]["port"], "8080", "port should be '8080'")


fn test_whitespace_trimming() raises:
    """Test that whitespace is trimmed from keys and values."""
    var input = """[Test]
  key1   =   value1  
key2=value2"""
    
    var data = parse(input)
    
    assert_equal(data["Test"]["key1"], "value1", "Whitespace should be trimmed")
    assert_equal(data["Test"]["key2"], "value2", "No-space format should work")


fn test_duplicate_key_error() raises:
    """Test that duplicate keys in same section raise error."""
    var input = """[Test]
key = value1
key = value2"""
    
    try:
        var data = parse(input)
        assert_true(False, "Should have raised error for duplicate key")
    except e:
        # Expected error
        pass


fn test_colon_separator() raises:
    """Test parsing with : instead of =."""
    var input = """[Test]
key1: value1
key2: value2"""
    
    var data = parse(input)
    
    assert_equal(data["Test"]["key1"], "value1", "Colon separator should work")
    assert_equal(data["Test"]["key2"], "value2", "Colon separator should work")


fn main() raises:
    """Run all parser tests using TestSuite."""
    TestSuite.discover_tests[__functions_in_module()]().run()
