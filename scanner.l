%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <cstring> // strerror
# include <string>
# include "driver.hh"
# include "parser.hh"
%}

%option noyywrap nounput noinput batch debug

%{
  // A number symbol corresponding to the value in S.
  yy::parser::symbol_type
  make_NUMBER (const std::string &s, const yy::parser::location_type& loc);
%}

id    [a-zA-Z][a-zA-Z_0-9]*
int   [0-9]+
blank [ \t\r]

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  loc.columns (yyleng);
%}
%%
%{
  // A handy shortcut to the location held by the driver.
  yy::location& loc = drv.location;
  // Code run each time yylex is called.
  loc.step ();
%}
{blank}+   loc.step ();
\n+        loc.lines (yyleng); loc.step ();
;          loc.step ();

"%"        return yy::parser::make_MOD    (loc);
"("        return yy::parser::make_LPAREN (loc);
")"        return yy::parser::make_RPAREN (loc);
"="        return yy::parser::make_ASSIGN (loc);
"?"        return yy::parser::make_THAN   (loc);
":"        return yy::parser::make_ELSE   (loc);
"<"        return yy::parser::make_LT     (loc);
"<="       return yy::parser::make_LE     (loc);
">"        return yy::parser::make_GT     (loc);
">="       return yy::parser::make_GE     (loc);
"=="       return yy::parser::make_EQ     (loc);
"!="       return yy::parser::make_NE     (loc);
"&&"       return yy::parser::make_AND    (loc);
"||"       return yy::parser::make_OR     (loc);

{int}      return make_NUMBER (yytext, loc);
{id}       return yy::parser::make_IDENTIFIER (yytext, loc);
.          {
             throw yy::parser::syntax_error
               (loc, "invalid character: " + std::string(yytext));
}
<<EOF>>    return yy::parser::make_YYEOF (loc);
%%

yy::parser::symbol_type
make_NUMBER (const std::string &s, const yy::parser::location_type& loc) {
    errno = 0;
    long n = strtol (s.c_str(), NULL, 10);
    if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE)) {
        throw yy::parser::syntax_error (loc, "integer is out of range: " + s);
    }
    return yy::parser::make_NUMBER ((int) n, loc);
}

void
driver::scan_begin () {
    yy_flex_debug = trace_scanning;
    buffer = yy_scan_string(file_contents.c_str());
}

void
driver::scan_end () {
    yy_delete_buffer(buffer);
}

