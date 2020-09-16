![C/C++ CI](https://github.com/limitz404/plurals-parser-bison/workflows/C/C++%20CI/badge.svg)

# plurals-parser

A CLI tool and library intended to dynamically parse C++ style ternary, mathematical, and boolean expressions used for Gettext Plural-Forms header.

## Building

```sh
git clone git@github.com:limitz404/plurals-parser-bison.git
cd plurals-parser-bison
make
```

## Usage

```sh
$ plurals-parser --help
plurals-parser is a CLI tool that computes the result of a Gettext plural-forms ternary.
Usage: ./plurals-parser [OPTIONS] [SUBCOMMAND]

Options:
  -h,--help                   Print this help message and exit

Subcommands:
  eval                        Evaluate a plural-forms ternary.
  test                        Run test suite.
```

```sh
$ plurals-parser eval --help
Evaluate a plural-forms ternary.
Usage: ./plurals-parser eval [OPTIONS] plural-forms

Positionals:
  plural-forms TEXT REQUIRED  A Gettext plural-forms ternary.

Options:
  -h,--help                   Print this help message and exit
  -n,--n UINT REQUIRED        The value of n.
  -p,--trace-parsing          Enable trace parsing.
  -s,--trace-scanning         Enable trace scanning.
  -v,--verbose                Be verbose.
```

```sh
$ plurals-parser test --help
Run test suite.
Usage: ./plurals-parser test [OPTIONS]

Options:
  -h,--help                   Print this help message and exit
  -v,--verbose                Be verbose.
```

### Example

```sh
$ plurals-parser test eval "(n % 100 == 1) ? 0 : ((n % 100 == 2) ? 1 : ((n % 100 == 3 || n % 100 == 4) ? 2 : 3))" --n=5 --verbose
Tests passed.
-----------------------------------
Statement: "(n % 100 == 1) ? 0 : ((n % 100 == 2) ? 1 : ((n % 100 == 3 || n % 100 == 4) ? 2 : 3))"
n: 5
Result: 3
-----------------------------------
3
```