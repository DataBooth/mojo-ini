"""Tests for error handling and edge cases.

These tests verify that the parser properly detects and reports errors
for invalid INI syntax, matching Python configparser behavior where appropriate.
"""

from std.testing import assert_true, TestSuite
from ini.parser import parse


def test_unclosed_section_header() raises:
    """Test that unclosed section header raises error."""
    var input = "[Section"

    try:
        var _ = parse(input)
        assert_true(False, "Should raise error for unclosed section")
    except e:
        # Expected - should contain "Unclosed"
        var err_msg = String(e)
        assert_true("Unclosed" in err_msg, "Error should mention unclosed section")


def test_duplicate_key_in_section() raises:
    """Test that duplicate keys in same section raise error."""
    var input = """[Test]
key = value1
key = value2"""

    try:
        var _ = parse(input)
        assert_true(False, "Should raise error for duplicate key")
    except e:
        # Expected - should mention "Duplicate"
        var err_msg = String(e)
        assert_true("Duplicate" in err_msg, "Error should mention duplicate key")


def test_missing_equals_sign() raises:
    """Test that missing equals sign raises error."""
    var input = """[Test]
key_without_equals"""

    try:
        var _ = parse(input)
        assert_true(False, "Should raise error for missing equals")
    except e:
        # Expected - should mention expecting '='
        var err_msg = String(e)
        assert_true("=" in err_msg or "Expected" in err_msg, "Error should mention missing =")


def test_empty_section_name() raises:
    """Test that empty section name is handled."""
    var input = "[]\nkey = value"

    # Python configparser allows empty section names
    var config = parse(input)
    # Just check that it doesn't crash - empty string key should exist
    assert_true("" in config, "Should handle empty section name")


def test_special_characters_in_values() raises:
    """Test that special characters in values are preserved."""
    var input = """[Test]
url = https://example.com/path?query=value&other=123
path = /path/with spaces/file.txt
email = user@example.com
brackets = [not a section]
equals = key=value inside value"""

    var config = parse(input)
    assert_true("?" in config["Test"]["url"], "Should preserve ? in URL")
    assert_true("&" in config["Test"]["url"], "Should preserve & in URL")
    assert_true(" " in config["Test"]["path"], "Should preserve spaces in path")
    assert_true("@" in config["Test"]["email"], "Should preserve @ in email")
    assert_true("[" in config["Test"]["brackets"], "Should preserve [ in value")
    assert_true("=" in config["Test"]["equals"], "Should preserve = in value")


def test_unicode_values() raises:
    """Test that Unicode characters are handled correctly."""
    var input = """[Test]
greeting = Hello, 世界!
emoji = 🔥 mojo-ini 🚀
cyrillic = Привет мир"""

    var config = parse(input)
    assert_true("世界" in config["Test"]["greeting"], "Should handle Chinese characters")
    assert_true("🔥" in config["Test"]["emoji"], "Should handle emoji")
    assert_true("Привет" in config["Test"]["cyrillic"], "Should handle Cyrillic")


def test_very_long_lines() raises:
    """Test that very long lines are handled."""
    var long_value = "x" * 10000
    var input = "[Test]\nkey = " + long_value

    var config = parse(input)
    assert_true(config["Test"]["key"].byte_length() == 10000, "Should handle very long values")


def test_many_sections() raises:
    """Test that many sections can be parsed."""
    var input = String("")
    for i in range(100):
        input += "[Section" + String(i) + "]\n"
        input += "key = value" + String(i) + "\n"

    var config = parse(input)
    # Should have 100 sections + default section
    assert_true(len(config) >= 100, "Should handle many sections (got " + String(len(config)) + ")")


def test_empty_file() raises:
    """Test that empty file is handled gracefully."""
    var config = parse("")
    # Should have at least the default section
    assert_true("" in config, "Empty file should have default section")


def test_only_comments() raises:
    """Test that file with only comments is handled."""
    var input = """# Comment 1
; Comment 2
# Comment 3"""

    var config = parse(input)
    assert_true("" in config, "Comment-only file should have default section")


def test_section_with_quotes() raises:
    """Test section names with quotes (Git config style)."""
    var input = """[remote "origin"]
url = https://github.com/user/repo.git"""

    var config = parse(input)
    # Section name should include the quotes
    assert_true('remote "origin"' in config, "Should preserve quotes in section name")


def main() raises:
    """Run all error handling tests using TestSuite."""
    TestSuite.discover_tests[__functions_in_module()]().run()
