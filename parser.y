// OBO Format 1.4 parser based on specification at
// http://owlcollab.github.io/oboformat/doc/obo-syntax.html
//
// Mara Kim

%{
package main

import (
)
%}

%union {
	string string;
}

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
	return eof;
}

// The parser calls this method on a parse error.
func (x *oboLex) Error(s string) {
	x.error = append(x.error, s)
}
