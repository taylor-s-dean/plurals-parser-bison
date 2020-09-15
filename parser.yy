%skeleton "lalr1.cc" // -*- C++ -*-
%require "3.6.4"
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
%define parse.error detailed
%define parse.lac full

%code {
# include "driver.hh"
}

%define api.token.prefix {TOK_}
%token
  ASSIGN  "="
  MOD     "%"
  THAN    "?"
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
;

%token <std::string> IDENTIFIER "identifier"
%token <int> NUMBER "number"
%nterm <int> expression
%nterm <int> if_statement
%nterm <int> multiplicative
%nterm <int> associative
%nterm <int> relational
%nterm <int> equality
%nterm <int> logical

%printer { yyo << $$; } <*>;

%%
%start unit;


%left "||";
%left "&&";
%left "==" "!=";
%left "<" "<=" ">" ">=";
%left "%";
%nonassoc "?" ":";

unit: assignments if_statement  { drv.result = $2; };

assignments:
  %empty                 {}
| assignments assignment {};

assignment:
  "identifier" "=" expression { drv.variables[$1] = $3; };

if_statement:
  expression
| expression "?" expression
| expression "?" expression ":" expression { $$ = $1 ? $3 : $5; }
;

multiplicative: expression "%" expression   { $$ = $1 % $3; };

associative: "(" expression ")"   { $$ = $2; };

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
