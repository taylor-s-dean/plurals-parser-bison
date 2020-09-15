all:
	bison -d parser.yy -o parser.cc;
	flex -o scanner.cc scanner.l;
	clang++ calc.cc driver.cc parser.cc scanner.cc -o calc -Wall -g -I../.nix-profile/include
