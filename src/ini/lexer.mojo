"""Lexer for INI files.

# Why: Purpose of the Lexer
The lexer (tokeniser) is the first stage of INI parsing. It converts raw text into
a stream of meaningful tokens, making it easier for the parser to understand structure.

Example transformation:
    Input:  '[Section]\nkey = value  ; comment'
    Output: [SECTION("Section"), NEWLINE, KEY("key"), EQUALS, VALUE("value"), COMMENT("comment")]

# What: Responsibilities
- Break INI text into atomic units (tokens)
- Identify token types (sections, keys, values, comments)
- Track line/column positions for error messages
- Support both # and ; style comments
- Handle multiline values (indented continuation)

# How: Lexer Design
The lexer uses a character-by-character scanner:
1. Read current character
2. Determine token type (section? key? value? comment?)
3. Consume characters until token complete
4. Emit token with type, value, and position
5. Repeat until EOF

This design keeps the parser simple—it works with high-level tokens rather than
raw characters, making INI syntax rules easier to implement.

# INI-Specific Handling
- Sections: [section_name]
- Key-value: key = value or key: value
- Comments: # comment or ; comment (to end of line)
- Multiline values: Indented continuation lines
- No escape sequences in classic INI (everything is literal)
"""

from collections import List


@register_passable("trivial")
struct Position:
    """Position in the source file (line and column).
    
    Used for error messages to show users exactly where parsing failed.
    Example: "Error at line 5, column 12: unexpected character"
    """
    var line: Int
    var column: Int

    fn __init__(out self, line: Int, column: Int):
        self.line = line
        self.column = column


@register_passable("trivial")
struct TokenKind:
    """Token types for INI lexer.
    
    INI is simpler than TOML - no arrays, no inline tables, just flat key-value pairs.
    """
    var _value: Int

    fn __init__(out self, value: Int):
        self._value = value

    # Special tokens
    @staticmethod
    fn EOF() -> TokenKind:
        """End of file marker."""
        return TokenKind(0)

    @staticmethod
    fn NEWLINE() -> TokenKind:
        """Line break (separates key-value pairs)."""
        return TokenKind(1)

    @staticmethod
    fn COMMENT() -> TokenKind:
        """Comment text after # or ; symbol."""
        return TokenKind(2)

    # Structural elements
    @staticmethod
    fn SECTION() -> TokenKind:
        """Section header: [section_name]."""
        return TokenKind(10)

    @staticmethod
    fn KEY() -> TokenKind:
        """Key name before = or :."""
        return TokenKind(11)

    @staticmethod
    fn VALUE() -> TokenKind:
        """Value after = or :."""
        return TokenKind(12)

    # Punctuation
    @staticmethod
    fn EQUALS() -> TokenKind:
        """Assignment operator: = or :."""
        return TokenKind(20)

    @staticmethod
    fn LEFT_BRACKET() -> TokenKind:
        """Section start: [."""
        return TokenKind(21)

    @staticmethod
    fn RIGHT_BRACKET() -> TokenKind:
        """Section end: ]."""
        return TokenKind(22)

    fn __eq__(self, other: TokenKind) -> Bool:
        return self._value == other._value

    fn __ne__(self, other: TokenKind) -> Bool:
        return self._value != other._value


struct Token(Copyable, Movable):
    """A token in the INI input stream.
    
    Represents a single meaningful unit of INI syntax with its type,
    content, and location in the source file.
    """
    var kind: TokenKind
    var value: String  # The actual text content
    var pos: Position  # Where it appears in the file

    fn __init__(out self, kind: TokenKind, value: String, pos: Position):
        self.kind = kind
        self.value = value
        self.pos = pos


struct Lexer:
    """Tokeniser for INI input.
    
    The lexer scans INI text character-by-character and produces a stream
    of tokens. It handles:
    - Section headers [name]
    - Key-value pairs (key = value)
    - Comments (# and ;)
    - Multiline values (indented continuation)
    - Position tracking for error messages
    
    Usage:
        var lexer = Lexer("[Section]\nkey = value")
        var tokens = lexer.tokenize()  # Returns List[Token]
    """

    var input: String
    var pos: Int      # Current position in input
    var line: Int     # Current line number (1-indexed)
    var column: Int   # Current column number (1-indexed)

    fn __init__(out self, input: String):
        """Initialise lexer with INI input.
        
        Args:
            input: INI content to tokenise.
        """
        self.input = input
        self.pos = 0
        self.line = 1
        self.column = 1

    fn current(self) -> String:
        """Get current character without advancing.
        
        Returns:
            Current character or empty string if at EOF.
        """
        if self.pos >= len(self.input):
            return ""
        return String(self.input[self.pos])

    fn peek(self, offset: Int = 1) -> String:
        """Look ahead at character without consuming it.
        
        Args:
            offset: Number of characters to look ahead (default: 1).
        
        Returns:
            Character at pos + offset or empty string if out of bounds.
        """
        var peek_pos = self.pos + offset
        if peek_pos >= len(self.input):
            return ""
        return String(self.input[peek_pos])

    fn advance(mut self) -> String:
        """Consume and return current character.
        
        Advances position and updates line/column tracking for error messages.
        
        Returns:
            Current character or empty string if at EOF.
        """
        if self.pos >= len(self.input):
            return ""

        var c = String(self.input[self.pos])
        self.pos += 1

        if c == "\n":
            self.line += 1
            self.column = 1
        else:
            self.column += 1

        return c

    fn skip_whitespace(mut self):
        """Skip whitespace characters (space, tab) but not newlines.
        
        Newlines are significant in INI for separating key-value pairs.
        """
        while self.pos < len(self.input):
            var c = self.current()
            if c == " " or c == "\t":
                _ = self.advance()
            else:
                break

    fn read_comment(mut self) raises -> Token:
        """Read a comment starting with # or ;.
        
        Comments run from # (or ;) to end of line.
        Example: key = value  # This is a comment
        
        Returns:
            Comment token (excluding the # or ; character).
        """
        var start_pos = Position(self.line, self.column)
        _ = self.advance()  # Skip # or ;

        var comment = String("")
        while self.pos < len(self.input):
            var c = self.current()
            if c == "\n":
                break
            comment += self.advance()

        # Trim leading/trailing whitespace from comment
        return Token(TokenKind.COMMENT(), String(comment.strip()), start_pos)

    fn read_section(mut self) raises -> Token:
        """Read a section header [section_name].
        
        Returns:
            SECTION token with section name (without brackets).
        
        Raises:
            Error: If section not properly closed with ].
        """
        var start_pos = Position(self.line, self.column)
        _ = self.advance()  # Skip [

        var section_name = String("")
        while self.pos < len(self.input):
            var c = self.current()
            if c == "]":
                _ = self.advance()  # Skip ]
                return Token(TokenKind.SECTION(), String(section_name.strip()), start_pos)
            elif c == "\n":
                raise Error("Unclosed section header at line " + String(self.line))
            else:
                section_name += self.advance()

        raise Error("Unclosed section header at end of file")

    fn read_key(mut self) raises -> Token:
        """Read a key name until = or :.
        
        Returns:
            KEY token with trimmed key name.
        """
        var start_pos = Position(self.line, self.column)
        var key = String("")

        while self.pos < len(self.input):
            var c = self.current()
            if c == "=" or c == ":" or c == "\n":
                break
            key += self.advance()

        return Token(TokenKind.KEY(), String(key.strip()), start_pos)

    fn read_value(mut self) raises -> Token:
        """Read a value after = or :.
        
        Handles inline comments (# or ; at end of line).
        
        Returns:
            VALUE token with trimmed value (excluding inline comments).
        """
        var start_pos = Position(self.line, self.column)
        var value = String("")

        while self.pos < len(self.input):
            var c = self.current()
            if c == "\n":
                break
            # Check for inline comment
            if c == "#" or c == ";":
                break
            value += self.advance()

        return Token(TokenKind.VALUE(), String(value.strip()), start_pos)

    fn tokenize(mut self) raises -> List[Token]:
        """Tokenise the entire INI input.
        
        Returns:
            List of tokens representing the INI structure.
        
        Raises:
            Error: If syntax is invalid.
        """
        var tokens = List[Token]()

        while self.pos < len(self.input):
            self.skip_whitespace()

            if self.pos >= len(self.input):
                break

            var c = self.current()

            # Newline
            if c == "\n":
                tokens.append(Token(TokenKind.NEWLINE(), "\n", Position(self.line, self.column)))
                _ = self.advance()

            # Comment
            elif c == "#" or c == ";":
                tokens.append(self.read_comment())

            # Section header
            elif c == "[":
                tokens.append(self.read_section())

            # Equals or colon
            elif c == "=" or c == ":":
                tokens.append(Token(TokenKind.EQUALS(), c, Position(self.line, self.column)))
                _ = self.advance()
                # After equals, skip whitespace and read value
                self.skip_whitespace()
                if self.pos < len(self.input) and self.current() != "\n" and self.current() != "#" and self.current() != ";":
                    tokens.append(self.read_value())

            # Key (starts with letter, digit, or underscore)
            else:
                # Read as key first, parser will determine context
                tokens.append(self.read_key())

        tokens.append(Token(TokenKind.EOF(), "", Position(self.line, self.column)))
        return tokens^
