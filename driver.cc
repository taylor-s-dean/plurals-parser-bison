#include "driver.hh"
#include "parser.hh"

driver::driver() : trace_parsing(false), trace_scanning(false) {
    variables["one"] = 1;
    variables["two"] = 2;
}

int
driver::parse(const std::string& f) {
    file_contents = f;
    std::string dummy_fname{"dummy.tern"};
    location.initialize(&dummy_fname);
    scan_begin();
    yy::parser parser(*this);
    parser.set_debug_level(trace_parsing);
    int res = parser.parse();
    scan_end();
    return res;
}
