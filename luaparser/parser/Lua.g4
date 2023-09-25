/*
BSD License

Copyright (c) 2013, Kazunori Sakamoto
Copyright (c) 2016, Alexander Alexeev
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the NAME of Rainer Schuster nor the NAMEs of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

This grammar file derived from:

    Luau 0.537 Grammar Documentation
    https://github.com/Roblox/luau/blob/0.537/docs/_pages/grammar.md

    Lua 5.4 Reference Manual
    http://www.lua.org/manual/5.4/manual.html

    Lua 5.3 Reference Manual
    http://www.lua.org/manual/5.3/manual.html

    Lua 5.2 Reference Manual
    http://www.lua.org/manual/5.2/manual.html

    Lua 5.1 grammar written by Nicolai Mainiero
    http://www.antlr3.org/grammar/1178608849736/Lua.g

Tested by Kazunori Sakamoto with Test suite for Lua 5.2 (http://www.lua.org/tests/5.2/)

Tested by Alexander Alexeev with Test suite for Lua 5.3 http://www.lua.org/tests/lua-5.3.2-tests.tar.gz

Tested by Matt Hargett with:
    - Test suite for Lua 5.4.4: http://www.lua.org/tests/lua-5.4.4-tests.tar.gz
    - Test suite for Selene Lua lint tool v0.20.0: https://github.com/Kampfkarren/selene/tree/0.20.0/selene-lib/tests
    - Test suite for full-moon Lua parsing library v0.15.1: https://github.com/Kampfkarren/full-moon/tree/main/full-moon/tests
    - Test suite for IntelliJ-Luanalysis IDE plug-in v1.3.0: https://github.com/Benjamin-Dobell/IntelliJ-Luanalysis/tree/v1.3.0/src/test
    - Test suite for StyLua formatting tool v.14.1: https://github.com/JohnnyMorganz/StyLua/tree/v0.14.1/tests
    - Entire codebase for luvit: https://github.com/luvit/luvit/
    - Entire codebase for lit: https://github.com/luvit/lit/
    - Entire codebase and test suite for neovim v0.7.2: https://github.com/neovim/neovim/tree/v0.7.2
    - Entire codebase for World of Warcraft Interface: https://github.com/tomrus88/BlizzardInterfaceCode
    - Benchmarks and conformance test suite for Luau 0.537: https://github.com/Roblox/luau/tree/0.537
*/

grammar Lua;

// options{
//     tokenVocab = V;
// }

AND       : 'and';
BREAK     : 'break';
DO        : 'do';
ELSETOK   : 'else';
ELSEIF    : 'elseif';
END       : 'end';
FALSE     : 'false';
FOR       : 'for';
FUNCTION  : 'function';
GOTO      : 'goto';
IFTOK     : 'if';
IN        : 'in';
LOCAL     : 'local';
NIL       : 'nil';
NOT       : 'not';
OR        : 'or';
REPEAT    : 'repeat';
RETURN    : 'return';
THEN      : 'then';
TRUE      : 'true';
UNTIL     : 'until';
WHILE     : 'while';
ADD       : '+';
MINUS     : '-';
MULT      : '*';
DIV       : '/';
FLOOR     : '//';
MOD       : '%';
POW       : '^';
LENGTH    : '#';
EQ        : '==';
NEQ       : '~=';
LTEQ      : '<=';
GTEQ      : '>=';
LT        : '<';
GT        : '>';
ASSIGN    : '=';
BITAND    : '&';
BITOR     : '|';
BITNOT    : '~';
BITRSHIFT : '>>';
BITRLEFT  : '<<';
OPAR      : '(';
CPAR      : ')';
OBRACE    : '{';
CBRACE    : '}';
OBRACK    : '[';
CBRACK    : ']';
COLCOL    : '::';
COL       : ':';
COMMA     : ',';
VARARGS   : '...';
CONCAT    : '..';
DOT       : '.';
SEMCOL     : ';';

chunk
    : block EOF
    ;

block
    : stat* laststat?
    ;

stat
    : SEMCOL
    | varlist ASSIGN explist
    | functioncall
    | label
    | BREAK
    | GOTO NAME
    | DO block END
    | WHILE exp DO block END
    | REPEAT block UNTIL exp
    | IFTOK exp THEN block (ELSEIF exp THEN block)* (ELSETOK block)? END
    | FOR NAME ASSIGN exp COMMA exp (COMMA exp)? DO block END
    | FOR namelist IN explist DO block END
    | FUNCTION funcname funcbody
    | LOCAL FUNCTION NAME funcbody
    | LOCAL attnamelist (ASSIGN explist)?
    ;

attnamelist
    : NAME attrib (COMMA NAME attrib)*
    ;

attrib
    : (LT NAME GT)?
    ;

laststat
    : RETURN explist? | BREAK | SEMCOL?
    ;

label
    : COLCOL NAME COLCOL
    ;

funcname
    : NAME (DOT NAME)* (COL NAME)?
    ;

varlist
    : var (COMMA var)*
    ;

namelist
    : NAME (COMMA NAME)*
    ;

explist
    : (exp COMMA)* exp
    ;

exp
    : NIL | FALSE | TRUE
    | NUMBER
    | STRING
    | VARARGS
    | functiondef
    | prefixexp
    | tableconstructor
    | <assoc=right> exp operatorPower exp
    | operatorUnary exp
    | exp operatorMulDivMod exp
    | exp operatorAddSub exp
    | <assoc=right> exp operatorStrcat exp
    | exp operatorComparison exp
    | exp operatorAnd exp
    | exp operatorOr exp
    | exp operatorBitwise exp
    ;

prefixexp
    : varOrExp nameAndArgs*
    ;

functioncall
    : varOrExp nameAndArgs+
    ;

varOrExp
    : var | OPAR exp CPAR
    ;

var
    : (NAME | OPAR exp CPAR varSuffix) varSuffix*
    ;

varSuffix
    : nameAndArgs* (OBRACK exp CBRACK | DOT NAME)
    ;

nameAndArgs
    : (COL NAME)? args
    ;

args
    : OPAR explist? CPAR | tableconstructor | STRING
    ;

functiondef
    : FUNCTION funcbody
    ;

funcbody
    : OPAR parlist? CPAR block END
    ;

parlist
    : namelist (COMMA VARARGS)? | VARARGS
    ;

tableconstructor
    : OBRACE fieldlist? CBRACE
    ;

fieldlist
    : field (fieldsep field)* fieldsep?
    ;

field
    : OBRACK exp CBRACK ASSIGN exp | NAME ASSIGN exp | exp
    ;

fieldsep
    : COMMA | SEMCOL
    ;

operatorOr
	: OR;

operatorAnd
	: AND;

operatorComparison
	: LT | GT | LTEQ | GTEQ | NEQ | EQ;

operatorStrcat
	: CONCAT;

operatorAddSub
	: ADD | MINUS;

operatorMulDivMod
	: MULT | DIV | MOD | FLOOR;

operatorBitwise
	: BITAND | BITOR | BITNOT | BITRLEFT | BITRSHIFT;

operatorUnary
    : NOT | LENGTH | MINUS | BITNOT;

operatorPower
    : POW;


// LEXER



NAME
    : [a-zA-Z_][a-zA-Z_0-9]*
    ;

NUMBER
    : Digit+ 
    | '0' [xX] HexDigit+ 
    | Digit+ '.' Digit* ExponentPart?
    | '.' Digit+ ExponentPart?
    | Digit+ ExponentPart 
    | '0' [xX] HexDigit+ '.' HexDigit* HexExponentPart?
    | '0' [xX] '.' HexDigit+ HexExponentPart?
    | '0' [xX] HexDigit+ HexExponentPart
    ;

STRING
    : '"' ( EscapeSequence | ~('\\'|'"') )* '"' | '\'' ( EscapeSequence | ~('\''|'\\') )* '\'' | '[' NESTED_STR ']'
    ;

fragment
NESTED_STR
    : '=' NESTED_STR '='
    | '[' .*? ']'
    ;

fragment
ExponentPart
    : [eE] [+-]? Digit+
    ;

fragment
HexExponentPart
    : [pP] [+-]? Digit+
    ;

fragment
EscapeSequence
    : '\\' [abfnrtvz"'|$#\\]   // World of Warcraft Lua additionally escapes |$# 
    | '\\' '\r'? '\n'
    | DecimalEscape
    | HexEscape
    | UtfEscape
    ;

fragment
DecimalEscape
    : '\\' Digit
    | '\\' Digit Digit
    | '\\' [0-2] Digit Digit
    ;

fragment
HexEscape
    : '\\' 'x' HexDigit HexDigit
    ;

fragment
UtfEscape
    : '\\' 'u{' HexDigit+ '}'
    ;

fragment
Digit
    : [0-9]
    ;

fragment
HexDigit
    : [0-9a-fA-F]
    ;

fragment
SingleLineInputCharacter
    : ~[\r\n\u0085\u2028\u2029]
    ;

COMMENT
    : '--[' NESTED_STR ']' -> channel(HIDDEN)
    ;

LINE_COMMENT
    : '--'
    (                                               // --
    | '[' '='*                                      // --[==
    | '[' '='* ~('='|'['|'\r'|'\n') ~('\r'|'\n')*   // --[==AA
    | ~('['|'\r'|'\n') ~('\r'|'\n')*                // --AAA
    )
    -> channel(HIDDEN)
    ;

SPACE
  : (' ' | '\t')+ -> channel(HIDDEN)
  ;

NEWLINE
  : ('\r\n' | '\r' | '\n' | '\u000C')+ -> channel(HIDDEN)
  ;

SHEBANG
    : '#' '!' SingleLineInputCharacter* -> channel(HIDDEN)
    ;
