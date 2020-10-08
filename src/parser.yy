%skeleton "lalr1.cc" // -*- C++ -*-
%require "3.5.1"
%defines

%define api.token.raw
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires {
  # include <string>
  class driver;
}

// The parsing context.
%param { driver& drv }

%locations

%define parse.trace
%define parse.error verbose
%define parse.lac full

%code {
# include "driver.hpp"
}

%define api.token.prefix {TOK_}
%token
  ASSIGN  "="
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
  YYEOF   0
;

%token <std::string> IDENTIFIER "identifier"
%token <uint> NUMBER "number"
%nterm <uint> expression
%nterm <uint> if_statement
%nterm <uint> multiplicative
%nterm <uint> associative
%nterm <uint> relational
%nterm <uint> equality
%nterm <uint> logical

%printer { yyo << $$; } <*>;

%%
%start unit;


%left "||";
%left "&&";
%left "==" "!=";
%left "<" "<=" ">" ">=";
%left "%";
%left "?";
%right ":";

unit: if_statement  { drv.result = $1; };

if_statement:
  expression
| expression "?" if_statement
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

void
yy::parser::error (const location_type& l, const std::string& m)
{
  std::cerr << l << ": " << m << '\n';
}
