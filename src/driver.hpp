#pragma once

#include <string>
#include <map>
#include "parser.hpp"

// Give Flex the prototype of yylex we want ...
#define YY_DECL yy::parser::symbol_type yylex(driver& drv)
// ... and declare it for the parser's sake.
YY_DECL;
typedef struct yy_buffer_state* YY_BUFFER_STATE;

// Conducting the whole scanning and parsing of Calc++.
class driver {
  public:
    typedef unsigned int uint;
    driver() : trace_parsing(false), trace_scanning(false) {}

    std::map<std::string, uint> variables;

    uint result;

    // Run the parser on file_contents.  Return 0 on success.
    int
    parse(const std::string& f, const uint n) {
        file_contents = f;
        location.initialize();
        variables["n"] = n;
        scan_begin();
        yy::parser parser(*this);
        parser.set_debug_level(trace_parsing);
        int res = parser.parse();
        scan_end();
        return res;
    }
    // The file contents to scan.
    std::string file_contents;
    YY_BUFFER_STATE buffer;

    // Whether to generate parser debug traces.
    bool trace_parsing;

    // Handling the scanner.
    void scan_begin();
    void scan_end();

    // Whether to generate scanner debug traces.
    bool trace_scanning;

    // The token's location used by the scanner.
    yy::location location;
};
