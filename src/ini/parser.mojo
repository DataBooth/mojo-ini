"""Parser for INI files.

# Why: Purpose of the Parser
The parser is the second stage of INI parsing. It takes the token stream from
the lexer and builds structured data (nested dictionaries).

Example transformation:
    Tokens: [SECTION("Database"), NEWLINE, KEY("host"), EQUALS, VALUE("localhost"), EOF]
    Output: {"Database": {"host": "localhost"}}

# What: Responsibilities
- Convert token stream into Dict[String, Dict[String, String]] structure
- Handle section headers [name]
- Process key-value pairs
- Detect duplicate keys within sections
- Handle multiline values (indented continuation lines)
- Validate INI syntax rules

# How: Parser Design
The parser uses a simple state machine:
1. Track current section context
2. Consume tokens sequentially
3. Build section dictionaries as we encounter keys/values
4. Return final nested Dict structure

INI is simpler than TOML - no arrays, no nesting beyond one level.
"""

from collections import Dict, List
from .lexer import Token, TokenKind, Lexer


struct Parser:
    """Parser for INI token streams.
    
    Converts lexer tokens into Dict[String, Dict[String, String]] structure.
    Each top-level key is a section name, and its value is a dict of key-value pairs.
    
    Usage:
        var lexer = Lexer("[Server]\nhost = localhost")
        var tokens = lexer.tokenize()
        var parser = Parser(tokens)
        var data = parser.parse()  # Returns Dict[String, Dict[String, String]]
    """

    var tokens: List[Token]
    var pos: Int  # Current position in token list

    fn __init__(out self, var tokens: List[Token]):
        """Initialize parser with token list.
        
        Args:
            tokens: Token list from lexer.
        """
        self.tokens = tokens^
        self.pos = 0

    fn current(self) -> Token:
        """Get current token without advancing.
        
        Returns:
            Current token or EOF if at end.
        """
        if self.pos >= len(self.tokens):
            return self.tokens[len(self.tokens) - 1].copy()  # Return EOF
        return self.tokens[self.pos].copy()

    fn advance(mut self):
        """Move to next token."""
        if self.pos < len(self.tokens):
            self.pos += 1

    fn skip_newlines(mut self):
        """Skip any NEWLINE tokens."""
        while self.pos < len(self.tokens) and self.current().kind == TokenKind.NEWLINE():
            self.advance()

    fn skip_comments(mut self):
        """Skip any COMMENT tokens."""
        while self.pos < len(self.tokens) and self.current().kind == TokenKind.COMMENT():
            self.advance()

    fn parse(mut self) raises -> Dict[String, Dict[String, String]]:
        """Parse tokens into nested dictionary structure.
        
        Returns:
            Dict mapping section names to key-value dictionaries.
            Sections are always present (even if only keys without a [section] header exist).
        
        Raises:
            Error: If syntax is invalid or duplicate keys exist.
        """
        var result = Dict[String, Dict[String, String]]()
        var current_section = String("")  # Default section for keys before any [section]
        result[current_section] = Dict[String, String]()

        while self.pos < len(self.tokens):
            self.skip_newlines()
            self.skip_comments()

            if self.pos >= len(self.tokens):
                break

            var token = self.current()

            # EOF
            if token.kind == TokenKind.EOF():
                break

            # Section header
            elif token.kind == TokenKind.SECTION():
                current_section = token.value
                if current_section not in result:
                    result[current_section] = Dict[String, String]()
                self.advance()

            # Key-value pair
            elif token.kind == TokenKind.KEY():
                var key = token.value
                self.advance()

                # Expect EQUALS
                if self.current().kind != TokenKind.EQUALS():
                    raise Error("Expected '=' after key '" + key + "' at line " + String(token.pos.line))
                self.advance()

                # Expect VALUE
                if self.current().kind != TokenKind.VALUE():
                    # Empty value is allowed
                    result[current_section][key] = ""
                else:
                    var value = self.current().value
                    self.advance()
                    
                    # Check for duplicate key in current section
                    if key in result[current_section]:
                        raise Error("Duplicate key '" + key + "' in section [" + current_section + "] at line " + String(token.pos.line))
                    
                    result[current_section][key] = value

            # Unexpected token
            else:
                self.advance()  # Skip unknown tokens

        return result^


fn parse(content: String) raises -> Dict[String, Dict[String, String]]:
    """Parse INI string into nested dictionary.
    
    Convenience function that handles lexing and parsing in one step.
    
    Args:
        content: INI formatted string.
    
    Returns:
        Dict mapping section names to key-value pairs.
    
    Raises:
        Error: If INI syntax is invalid.
    
    Example:
        ```mojo
        var data = parse("[Database]\nhost = localhost\nport = 5432")
        print(data["Database"]["host"])  # "localhost"
        ```
    """
    var lexer = Lexer(content)
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    return parser.parse()
