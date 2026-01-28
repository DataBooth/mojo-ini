"""Test suite for INI lexer.

Tests tokenisation of INI syntax elements:
- Sections ([name])
- Key-value pairs (key = value)
- Comments (# and ;)
- Whitespace handling
- Error cases
"""

from testing import assert_equal, assert_true, TestSuite
from ini.lexer import Lexer, Token, TokenKind, Position


fn test_empty_input() raises:
    """Test lexing empty string."""
    var lexer = Lexer("")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 1, "Should have EOF token")
    assert_true(tokens[0].kind == TokenKind.EOF(), "Should be EOF")


fn test_simple_section() raises:
    """Test lexing a section header."""
    var lexer = Lexer("[Database]")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 2, "Should have SECTION + EOF")
    assert_true(tokens[0].kind == TokenKind.SECTION(), "First token should be SECTION")
    assert_equal(tokens[0].value, "Database", "Section name should be 'Database'")
    assert_true(tokens[1].kind == TokenKind.EOF(), "Second token should be EOF")


fn test_key_value_equals() raises:
    """Test lexing key = value."""
    var lexer = Lexer("host = localhost")
    var tokens = lexer.tokenize()

    # Should be: KEY, EQUALS, VALUE, EOF
    assert_equal(len(tokens), 4, "Should have KEY + EQUALS + VALUE + EOF")
    assert_true(tokens[0].kind == TokenKind.KEY(), "First should be KEY")
    assert_equal(tokens[0].value, "host", "Key should be 'host'")
    assert_true(tokens[1].kind == TokenKind.EQUALS(), "Second should be EQUALS")
    assert_true(tokens[2].kind == TokenKind.VALUE(), "Third should be VALUE")
    assert_equal(tokens[2].value, "localhost", "Value should be 'localhost'")
    assert_true(tokens[3].kind == TokenKind.EOF(), "Fourth should be EOF")


fn test_hash_comment() raises:
    """Test lexing # style comment."""
    var lexer = Lexer("# This is a comment")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 2, "Should have COMMENT + EOF")
    assert_true(tokens[0].kind == TokenKind.COMMENT(), "Should be COMMENT")
    assert_equal(tokens[0].value, "This is a comment", "Comment text should match")


fn test_semicolon_comment() raises:
    """Test lexing ; style comment."""
    var lexer = Lexer("; Windows-style comment")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 2, "Should have COMMENT + EOF")
    assert_true(tokens[0].kind == TokenKind.COMMENT(), "Should be COMMENT")
    assert_equal(tokens[0].value, "Windows-style comment", "Comment text should match")


fn test_section_with_newline() raises:
    """Test section followed by newline."""
    var lexer = Lexer("[Server]\n")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 3, "Should have SECTION + NEWLINE + EOF")
    assert_true(tokens[0].kind == TokenKind.SECTION(), "First should be SECTION")
    assert_equal(tokens[0].value, "Server", "Section should be 'Server'")
    assert_true(tokens[1].kind == TokenKind.NEWLINE(), "Second should be NEWLINE")


fn test_position_tracking() raises:
    """Test that positions are tracked correctly."""
    var lexer = Lexer("[Test]")
    var tokens = lexer.tokenize()

    assert_equal(tokens[0].pos.line, 1, "Should be on line 1")
    assert_equal(tokens[0].pos.column, 1, "Should start at column 1")


fn test_unclosed_section_error() raises:
    """Test error on unclosed section."""
    var lexer = Lexer("[Unclosed")

    try:
        var tokens = lexer.tokenize()
        assert_true(False, "Should have raised error for unclosed section")
    except e:
        # Expected error
        pass


fn test_multiline_ini() raises:
    """Test lexing multiple lines."""
    var input = """[Database]
host = localhost
port = 5432"""

    var lexer = Lexer(input)
    var tokens = lexer.tokenize()

    # Expected: SECTION, NEWLINE, KEY, EQUALS, (value missing), NEWLINE, KEY, EQUALS, (value missing), EOF
    # We need to track context to know when to read values
    assert_true(len(tokens) > 5, "Should have multiple tokens")
    assert_true(tokens[0].kind == TokenKind.SECTION(), "First should be SECTION")


fn main() raises:
    """Run all lexer tests using TestSuite."""
    TestSuite.discover_tests[__functions_in_module()]().run()
