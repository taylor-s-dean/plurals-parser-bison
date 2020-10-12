LEX = flex
YACC = bison
CXX = g++
GCOVR = gcovr

ODIR = obj
SDIR = src
GCOV = code-coverage

CFLAGS_DEFAULT = -I./$(SDIR)                   \
				 -I./third_party/CLI11/include \
				 -g                            \
				 -Werror                       \
				 -Wall                         \
				 -Wextra                       \
				 -Wshadow                      \
				 -Wdouble-promotion            \
				 -Wformat=2                    \
				 -Wundef                       \
				 -Wconversion                  \
				 -fno-common                   \
				 -Wno-logical-op-parentheses   \
				 -Wno-parentheses              \
				 -Wno-sign-conversion

all: CFLAGS = $(CFLAGS_DEFAULT) \
			  -O1

test: CFLAGS = $(CFLAGS_DEFAULT)       \
			   -fkeep-inline-functions \
			   -fkeep-static-functions \
			   --coverage

.PHONY: all clean
.SECONDARY: main-build

all: pre-build main-build

main-build: plurals-parser

plurals-parser: $(ODIR)/plurals-parser.o $(ODIR)/scanner.o $(ODIR)/parser.o $(ODIR)/driver.o
	$(CXX) -o $@ $^ $(CFLAGS)

$(ODIR)/plurals-parser.o: $(SDIR)/plurals-parser.cpp $(SDIR)/parser.hpp
	$(CXX) -c -o $@ $< $(CFLAGS)

$(ODIR)/driver.o: $(SDIR)/driver.cpp $(SDIR)/driver.hpp $(SDIR)/parser.hpp
	$(CXX) -c -o $@ $< $(CFLAGS)

$(ODIR)/parser.o: $(SDIR)/parser.cpp $(SDIR)/parser.hpp
	$(CXX) -c -o $@ $< $(CFLAGS)

$(ODIR)/scanner.o: $(SDIR)/scanner.cpp $(SDIR)/parser.hpp
	$(CXX) -c -o $@ $< $(CFLAGS)

$(SDIR)/scanner.cpp: $(SDIR)/scanner.ll
	$(LEX) -o $(SDIR)/scanner.cpp $<

$(SDIR)/parser.cpp $(SDIR)/parser.hpp: $(SDIR)/parser.yy
	$(YACC) -d -o $(SDIR)/parser.cpp $<

pre-build:
	@if git submodule status | egrep -q '^[-]|^[+]' ; then      \
		echo "INFO: Need to reinitialize git submodules";       \
		git submodule update --init;                            \
	else                                                        \
		echo "INFO: No need to reinitialize git submodules";    \
	fi
	@if test ! -d $(ODIR) ; then \
		mkdir $(ODIR);           \
	fi

test: pre-build plurals-parser
	@if hash $(GCOVR); then \
		./plurals-parser \
			test \
				--verbose \
			eval \
				--trace-parsing \
				--trace-scanning \
				--verbose \
				--n=5 \
				"n > 3 ? 1 : 0;" > /dev/null 2>&1 && echo "All tests passed" || exit 1; \
		mkdir -p $(GCOV); \
		$(GCOVR) \
			--filter $(SDIR)/scanner.ll \
			--filter $(SDIR)/parser.yy \
			--filter $(SDIR)/driver.cpp \
			--filter $(SDIR)/driver.hpp \
			--filter $(SDIR)/plurals-parser.cpp \
			--exclude-unreachable-branches \
			--exclude-throw-branches \
			--html \
			--html-details \
			-j 8 \
			--output $(GCOV)/code-coverage.html; \
	else \
		echo "INFO: $(GCOVR) is not installed on the system. Please install with \"pip install $(GCOVR)\""; \
		exit 1; \
	fi


clean:
	@rm -rf \
		$(ODIR) \
		$(GCOV) \
		*~ \
		core \
		$(SDIR)/parser.cpp \
		$(SDIR)/parser.hpp \
		$(SDIR)/scanner.cpp \
		$(SDIR)/location.hh \
		./plurals-parser
