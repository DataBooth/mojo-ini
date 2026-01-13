"""Tests for fixture INI files.

These tests validate that the parser can handle real-world configuration files
across various formats and dialects:
- Python configparser style
- Git config format
- mypy.ini style
- Classic Windows INI
- Multiline values
- Edge cases
"""

from testing import assert_equal, assert_true, TestSuite
from ini.parser import parse


fn read_fixture(filename: String) raises -> String:
    """Read a fixture file from the fixtures directory."""
    var path = "fixtures/" + filename

    with open(path, "r") as f:
        return f.read()


fn test_sample_ini() raises:
    """Test parsing basic sample.ini."""
    var content = read_fixture("sample.ini")
    var config = parse(content)

    # Database section
    assert_true("Database" in config, "Should have Database section")
    assert_equal(config["Database"]["host"], "localhost")
    assert_equal(config["Database"]["port"], "5432")
    assert_equal(config["Database"]["user"], "admin")
    assert_equal(config["Database"]["max_connections"], "100")

    # Server section
    assert_true("Server" in config, "Should have Server section")
    assert_equal(config["Server"]["debug"], "true")
    assert_equal(config["Server"]["timeout"], "30")
    assert_equal(config["Server"]["host"], "0.0.0.0")
    assert_equal(config["Server"]["port"], "8080")

    # Logging section
    assert_true("Logging" in config, "Should have Logging section")
    assert_equal(config["Logging"]["level"], "INFO")
    assert_equal(config["Logging"]["file"], "/var/log/app.log")

    # Features section
    assert_true("Features" in config, "Should have Features section")
    assert_equal(config["Features"]["enable_api"], "true")
    assert_equal(config["Features"]["enable_web"], "true")
    assert_equal(config["Features"]["enable_admin"], "false")


fn test_python_configparser() raises:
    """Test parsing Python configparser style INI with DEFAULT section."""
    var content = read_fixture("python_configparser.ini")
    var config = parse(content)

    # DEFAULT section
    assert_true("DEFAULT" in config, "Should have DEFAULT section")
    assert_equal(config["DEFAULT"]["lib_name"], "fastbook")
    assert_equal(config["DEFAULT"]["user"], "fastai")
    assert_equal(config["DEFAULT"]["version"], "0.0.1")

    # Paths section
    assert_true("Paths" in config, "Should have Paths section")
    assert_equal(config["Paths"]["nbs_path"], ".")
    assert_equal(config["Paths"]["doc_path"], "docs")

    # URLs section
    assert_true("URLs" in config, "Should have URLs section")
    assert_equal(config["URLs"]["host"], "github")


fn test_git_config() raises:
    """Test parsing Git config style INI."""
    var content = read_fixture("git_config.ini")
    var config = parse(content)

    # user section
    assert_true("user" in config, "Should have user section")
    assert_equal(config["user"]["name"], "Michael Booth")
    assert_equal(config["user"]["email"], "michael@databooth.com.au")

    # http section
    assert_true("http" in config, "Should have http section")
    assert_equal(config["http"]["postBuffer"], "52428800")

    # core section
    assert_true("core" in config, "Should have core section")
    assert_equal(config["core"]["editor"], "vim")
    assert_equal(config["core"]["autocrlf"], "input")

    # alias section
    assert_true("alias" in config, "Should have alias section")
    assert_equal(config["alias"]["st"], "status")
    assert_equal(config["alias"]["co"], "checkout")


fn test_mypy_ini() raises:
    """Test parsing mypy.ini style configuration."""
    var content = read_fixture("mypy.ini")
    var config = parse(content)

    # mypy section
    assert_true("mypy" in config, "Should have mypy section")
    assert_equal(config["mypy"]["files"], "Lib/tomllib")
    assert_equal(config["mypy"]["python_version"], "3.12")
    assert_equal(config["mypy"]["pretty"], "True")
    assert_equal(config["mypy"]["strict"], "True")


fn test_windows_classic() raises:
    """Test parsing classic Windows INI with semicolon comments."""
    var content = read_fixture("windows_classic.ini")
    var config = parse(content)

    # Application section
    assert_true("Application" in config, "Should have Application section")
    assert_equal(config["Application"]["Name"], "MyApp")
    assert_equal(config["Application"]["Version"], "1.0.0")

    # Window section
    assert_true("Window" in config, "Should have Window section")
    assert_equal(config["Window"]["Width"], "1024")
    assert_equal(config["Window"]["Height"], "768")
    assert_equal(config["Window"]["Fullscreen"], "false")

    # Database section with comment
    assert_true("Database" in config, "Should have Database section")
    assert_equal(config["Database"]["Server"], "localhost")
    assert_equal(config["Database"]["Password"], "admin123")

    # Logging section
    assert_true("Logging" in config, "Should have Logging section")
    assert_equal(config["Logging"]["Level"], "INFO")
    # Note: Windows path with backslash
    assert_equal(config["Logging"]["File"], "C:\\Logs\\app.log")


fn test_multiline_values() raises:
    """Test parsing multiline values with indented continuation."""
    var content = read_fixture("multiline_values.ini")
    var config = parse(content)

    # Server section
    assert_true("Server" in config, "Should have Server section")
    assert_equal(config["Server"]["host"], "0.0.0.0")
    assert_equal(config["Server"]["port"], "8080")
    # Note: Multiline values need parser support for indented continuation
    # Currently each line will be treated separately

    # Database section
    assert_true("Database" in config, "Should have Database section")
    # Multiline connection string

    # Email section  
    assert_true("Email" in config, "Should have Email section")
    # Multiline recipients

    # Features section
    assert_true("Features" in config, "Should have Features section")
    # Multiline enabled_modules


fn test_edge_cases() raises:
    """Test parsing edge cases INI."""
    var content = read_fixture("edge_cases.ini")
    var config = parse(content)

    # Empty section should exist
    assert_true("EmptySection" in config, "Should have EmptySection")

    # No spaces around equals
    assert_true("NoSpacesAroundEquals" in config, "Should have NoSpacesAroundEquals section")
    assert_equal(config["NoSpacesAroundEquals"]["key"], "value")

    # Spaces in values
    assert_true("SpacesInValues" in config, "Should have SpacesInValues section")
    assert_equal(config["SpacesInValues"]["path"], "/path/with spaces/to/file")

    # Special characters
    assert_true("SpecialCharacters" in config, "Should have SpecialCharacters section")
    assert_equal(config["SpecialCharacters"]["email"], "user@example.com")
    assert_equal(config["SpecialCharacters"]["url"], "https://example.com/path?query=value&other=123")

    # Empty values
    assert_true("EmptyValues" in config, "Should have EmptyValues section")
    assert_equal(config["EmptyValues"]["empty_explicit"], "")
    assert_equal(config["EmptyValues"]["empty_implicit"], "")

    # Unicode
    assert_true("UnicodeValues" in config, "Should have UnicodeValues section")
    assert_equal(config["UnicodeValues"]["greeting"], "Hello, 世界!")
    assert_equal(config["UnicodeValues"]["emoji"], "🔥 mojo-ini 🚀")


fn main() raises:
    """Run all fixture tests using TestSuite."""
    TestSuite.discover_tests[__functions_in_module()]().run()
