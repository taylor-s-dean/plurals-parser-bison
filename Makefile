LEX = flex
YACC = bison
CXX = clang++

ODIR = obj
SDIR = src

CFLAGS = -I./$(SDIR)                   \
		 -I./third_party/CLI11/include \
		 -O1                           \
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
		 -Wno-logical-op-parentheses

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
	@if git submodule status | egrep -q '^[-]|^[+]' ; then 		                         \
		echo "INFO: Need to reinitialize git submodules"; 		                         \
		git submodule update --init; 							                         \
	else 														                         \
		echo "INFO: No need to reinitialize git submodules"; 	                         \
	fi
	@if test ! -d $(ODIR) ; then \
		mkdir $(ODIR);           \
	fi

test: pre-build plurals-parser
	./plurals-parser test

clean:
	rm -rf $(ODIR)          \
		*~                  \
		core                \
		$(SDIR)/parser.cpp  \
		$(SDIR)/parser.hpp  \
		$(SDIR)/scanner.cpp \
		./plurals-parser
