#include "driver.hpp"
#include "parser.hpp"

driver::driver() : trace_parsing(false), trace_scanning(false) {}

int
driver::parse(const std::string& f, const uint n) {
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
