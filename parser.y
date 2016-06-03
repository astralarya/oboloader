// OBO Format 1.4 parser based on specification at
// http://owlcollab.github.io/oboformat/doc/obo-syntax.html
//
// Mara Kim

%{
package main

import (
	"unicode/utf8"
	"strings"
)
%}

%union {
	rune
	string
}

%token <rune> ALPHA
%token <rune> DIGIT
%token <rune> WHITESPACE
%token <rune> NEWLINE
%token <rune> OBOCHAR

%%

top:
	{
	}

%%

// The parser expects the lexer to return 0 on EOF.  Give it a name
// for clarity.
const eof = 0

// The parser uses the type <prefix>Lex as a lexer.  It must provide
// the methods Lex(*<prefix>SymType) int and Error(string).
type oboLex struct {
	line []byte
	peek rune
	error []string
}

// The parser calls this method to get each new token.
func (x *oboLex) Lex(yylval *oboSymType) int {
	escape := false;
	for {
		c := x.next();
		if c == eof {
			return eof
		} else if escape {
			escape = false;
			yylval.rune = c;
			if whitespaceChar(c) {
				return WHITESPACE
			} else {
				return OBOCHAR
			}
		} else if alphaChar(c) {
			yylval.rune = c;
			return ALPHA
		} else if digit(c) {
			yylval.rune = c;
			return DIGIT
		} else if whitespaceChar(c) {
			yylval.rune = c;
			return WHITESPACE
		} else if newlineChar(c) {
			yylval.rune = c;
			return NEWLINE
		} else if c == '\\' {
			escape = true;
		} else if oboChar(c) {
			yylval.rune = c;
			return OBOCHAR
		}
	}
}

// The parser calls this method on a parse error.
func (x *oboLex) Error(s string) {
	x.error = append(x.error, s)
}

// Return the next rune for the lexer.
func (x *oboLex) next() rune {
	if x.peek != eof {
		r := x.peek
		x.peek = eof
		return r
	}
	if len(x.line) == 0 {
		return eof
	}
	c, size := utf8.DecodeRune(x.line)
	x.line = x.line[size:]
	if c == utf8.RuneError && size == 1 {
		x.error = append(x.error, "Invalid utf8")
		return x.next()
	}
	return c
}

// Basic Characters

func alphaChar(c rune) bool {
	return 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z';
}

func digit(c rune) bool {
	return '0' <= c && c <= '9';
}

// Spacing Characters

func whitespaceChar(c rune) bool {
	return strings.ContainsRune(" \t\u0020\u0009",c);
}

func newlineChar(c rune) bool {
	return strings.ContainsRune("\r\n\u000A\u000C\u000D",c);
}

// Special Characters

func oboChar(c rune) bool {
	return !newlineChar(c) && c != '\\';
}
