%{ /* -*- C++ -*- */
    #ifdef __clang__
    #pragma clang diagnostic ignored "-Wnull-conversion"
    #endif
    #include <cerrno>
    #include <climits>
    #include <cstdlib>
    #include <cstring> // strerror
    #include <string>
    #include <sstream>
    #include "driver.hpp"
    #include "parser.hpp"
%}

%option noyywrap nounput noinput batch debug prefix="PP"

%{
    // A number symbol corresponding to the value in S.
    pp::parser::symbol_type
    make_NUMBER(const std::string &s, const pp::parser::location_type& loc, driver& drv);
%}

id      [a-zA-Z][a-zA-Z_0-9]*
int     [0-9]+
blank   [ \t\r]

%{
    // Code run each time a pattern is matched.
    # define YY_USER_ACTION  loc.columns (yyleng);
%}

%%

%{
    // A handy shortcut to the location held by the driver.
    pp::location& loc = drv.location;
    // Code run each time yylex is called.
    loc.step ();
%}

{blank}+    loc.step();
;           loc.step();
\n+         {
                loc.lines(yyleng);
                loc.step();
            }

{id}        return pp::parser::make_IDENTIFIER  (yytext, loc);
{int}       return make_NUMBER                  (yytext, loc, drv);
"%"         return pp::parser::make_MOD         (loc);
"?"         return pp::parser::make_THEN        (loc);
":"         return pp::parser::make_ELSE        (loc);
"<"         return pp::parser::make_LT          (loc);
"<="        return pp::parser::make_LE          (loc);
">"         return pp::parser::make_GT          (loc);
">="        return pp::parser::make_GE          (loc);
"=="        return pp::parser::make_EQ          (loc);
"!="        return pp::parser::make_NE          (loc);
"&&"        return pp::parser::make_AND         (loc);
"||"        return pp::parser::make_OR          (loc);
"("         return pp::parser::make_LPAREN      (loc);
")"         return pp::parser::make_RPAREN      (loc);
<<EOF>>     return pp::parser::make_PPEOF       (loc);
.           {
                std::stringstream ss;
                ss << "plurals-parser: syntax error["
                   << loc
                   << "] encountered invalid character \""
                   << yytext
                   << "\" while parsing \""
                   << drv.file_contents
                   << "\"";
                drv.error =  ss.str();

                return pp::parser::make_PPerror(loc);
            }

%%

pp::parser::symbol_type
make_NUMBER (const std::string &s, const pp::parser::location_type& loc, driver& drv) {
    errno = 0;
    long n = strtol(s.c_str(), NULL, 10);
    if (!(INT_MIN <= n && n <= INT_MAX && errno != ERANGE)) {
        std::stringstream ss;
        ss << "plurals-parser: error["
           << loc
           << "] integer is out of range ("
           << INT_MIN
           << ", "
           << INT_MAX
           << "): "
           << s;
        drv.error = ss.str();
        return pp::parser::make_PPerror(loc);
    }
    return pp::parser::make_NUMBER((uint) n, loc);
}

void driver::scan_begin() {
    yy_flex_debug = trace_scanning;
    buffer = yy_scan_string(file_contents.c_str());
}

void driver::scan_end() {
    yy_delete_buffer(buffer);
}

