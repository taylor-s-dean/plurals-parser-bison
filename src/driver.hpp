#pragma once

#include <string>
#include <map>
#include "parser.hpp"

// Give Flex the prototype of pplex we want ...
#define YY_DECL pp::parser::symbol_type pplex(driver& drv)
// ... and declare it for the parser's sake.
YY_DECL;
typedef struct yy_buffer_state* YY_BUFFER_STATE;

// Conducting the whole scanning and parsing of Calc++.
class driver {
  public:
    typedef unsigned int uint;
    driver() : trace_parsing(false), trace_scanning(false) {}

    // Run the parser on file_contents.  Return 0 on success.
    int
    parse(const std::string& f, const uint n) {
        file_contents = f;
        location.initialize();
        variables["n"] = n;
        scan_begin();
        pp::parser parser(*this);
        parser.set_debug_level(trace_parsing);
        int res = parser.parse();
        scan_end();
        return res;
    }

    // Handling the scanner.
    void scan_begin();
    void scan_end();

    YY_BUFFER_STATE buffer;

    // Whether to generate parser debug traces.
    bool trace_parsing;

    // Whether to generate scanner debug traces.
    bool trace_scanning;

    // The token's location used by the scanner.
    pp::location location;

    std::map<std::string, uint> variables;
    std::string file_contents;
    uint result;
    std::string error;
};
