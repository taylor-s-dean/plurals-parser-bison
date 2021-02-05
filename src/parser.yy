%skeleton "lalr1.cc" // -*- C++ -*-
%require "3.2"
%defines

%define api.prefix {pp}
%define api.token.constructor
%define api.token.prefix {TOK_}
%define api.value.type variant
%define parse.assert
%define parse.trace
%define parse.error verbose
%define lr.type ielr
%locations

%code requires {
    #include <string>
    class driver;
}

%code provides {
    #include "driver.hpp"
}

%param { driver& drv }

%token <std::string> IDENTIFIER "identifier"
%token <uint> NUMBER "number"
%token
    MOD     "%"
    THEN    "?"
    ELSE    ":"
    LT      "<"
    LE      "<="
    GT      ">"
    GE      ">="
    EQ      "=="
    NE      "!="
    AND     "&&"
    OR      "||"
    LPAREN  "("
    RPAREN  ")"
    PPEOF    0
;

%nterm <uint>
    expression
    if_statement
    multiplicative
    associative
    relational
    equality
    logical
;

%printer { yyo << $$; } <*>;

%%
%left "||";
%left "&&";
%left "==" "!=";
%left "<" "<=" ">" ">=";
%left "%";
%left "?";
%right ":";

%start unit;

unit: if_statement  { drv.result = $1; };

if_statement:
  expression
| expression "?" if_statement ":" if_statement { $$ = $1 ? $3 : $5; }
;

multiplicative: expression "%" expression   { $$ = $1 % $3; };

associative: "(" if_statement ")"   { $$ = $2; };

relational:
  expression "<" expression  { $$ = $1 < $3; }
| expression "<=" expression { $$ = $1 <= $3; }
| expression ">" expression  { $$ = $1 > $3; }
| expression ">=" expression { $$ = $1 >= $3; }
;

equality:
  expression "==" expression { $$ = $1 == $3; }
| expression "!=" expression { $$ = $1 != $3; }
;

logical:
  expression "&&" expression { $$ = $1 && $3; }
| expression "||" expression { $$ = $1 || $3; }
;

expression:
  "number"
| "identifier"  { $$ = drv.variables[$1]; }
| associative
| multiplicative
| relational
| equality
| logical
;
%%

void pp::parser::error (const location_type& l, const std::string& m) {
    std::cerr << l << ": " << m << '\n';
}
