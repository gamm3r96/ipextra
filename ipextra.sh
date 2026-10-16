#!/bin/sh
# ipextra - extract IPv4 addresses from text using awk (author Gamm3r96)
# https://github.com/gamm3r96/ipextra
#
# Modes:
#   extract  (default) print every valid IPv4 found, one per line
#   grep     print whole lines that contain an IP (or match --pattern)
#   count    print the number of valid IPs found
#   validate check each candidate token and report OK/BAD

AWK_LIB="${IPEXTRA_AWK:-/usr/share/ipextra/ipextra.awk}"

usage() {
    cat <<'EOF'
Usage: ipextra [OPTIONS] [FILE...]
       ipextra [OPTIONS] < input.txt

Extract IPv4 addresses from text. Reads FILEs or stdin; prints one IP per line.

Modes:
  -e, --extract         print every valid IPv4 address found (default)
  -g, --grep            print whole lines that contain an IPv4 address
  -c, --count           print how many valid IPv4 addresses were found
  -V, --validate        label each candidate token OK or BAD

Options:
  -u, --unique          report each distinct address only once
  -s, --sort            sort output numerically by IP address
  -p, --pattern=REGEX   in grep mode, match this regex instead of IPs
  -q, --quiet           suppress informational messages
  -h, --help            show this help and exit
      --version         show version and exit

Examples:
  ipextra < access.log              # list all IPs
  ipextra -u -s file1 file2         # unique, sorted across files
  ipextra -g 'server .* up' log     # grep-style line filter via pattern
  ipextra -c netstat.out            # count addresses
  echo 10.0.0.999 | ipextra -V     # validate a token

Exit status:
  0  success
  1  invalid option / usage error
  2  at least one BAD result in --validate mode
EOF
}

MODE=extract
VERBOSE=1
UNIQUE=0
SORTED=0
PATTERN=
FILELIST=""   # newline-separated list of file operands

while [ $# -gt 0 ]; do
    case "$1" in
        -e|--extract)  MODE=extract ;;
        -g|--grep)     MODE=grep ;;
        -c|--count)    MODE=count ;;
        -V|--validate) MODE=validate ;;
        -u|--unique)   UNIQUE=1 ;;
        -s|--sort)     SORTED=1 ;;
        -p|--pattern)  shift; [ $# -gt 0 ] || { echo "ipextra: --pattern needs an argument" >&2; exit 1; }; PATTERN=$1 ;;
        --pattern=*)   PATTERN=${1#*=} ;;
        -q|--quiet)    VERBOSE=0 ;;
        -h|--help)     usage; exit 0 ;;
        --version)     echo "ipextra 1.1"; exit 0 ;;
        --)            shift
                      while [ $# -gt 0 ]; do
                          FILELIST="$FILELIST$1
"; shift
                      done ;;
        -*)            echo "ipextra: unknown option: $1" >&2; usage >&2; exit 1 ;;
        *)             FILELIST="$FILELIST$1
" ;;
    esac
    shift
done

if [ ! -f "$AWK_LIB" ]; then
    echo "ipextra: awk library not found at $AWK_LIB (reinstall the ipextra package?)" >&2
    exit 1
fi

RC=0
MARKER=""
if [ "$MODE" = validate ]; then
    # awk signals "BAD found" through a marker file so the wrapper can exit
    # with status 2 (an awk variable cannot cross back into the shell).
    MARKER=$(mktemp 2>/dev/null || echo "/tmp/ipextra.$$.marker")
    rm -f "$MARKER"
fi

if [ "$FILELIST" = "" ]; then
    awk -v MODE="$MODE" -v VERBOSE="$VERBOSE" -v UNIQUE="$UNIQUE" \
        -v SORTED="$SORTED" -v PATTERN="$PATTERN" -v MARKER="$MARKER" \
        -f "$AWK_LIB" || RC=$?
else
    # Feed each file operand as a single argument (handles spaces in names).
    OLDIFS=$IFS
    IFS='
'
    set -f   # disable globbing on filenames
    # shellcheck disable=SC2086
    set -- $FILELIST
    IFS=$OLDIFS
    set +f
    awk -v MODE="$MODE" -v VERBOSE="$VERBOSE" -v UNIQUE="$UNIQUE" \
        -v SORTED="$SORTED" -v PATTERN="$PATTERN" -v MARKER="$MARKER" \
        -f "$AWK_LIB" "$@" || RC=$?
fi

if [ "$MODE" = validate ]; then
    if [ -s "$MARKER" ]; then RC=2; fi
    rm -f "$MARKER"
fi

exit $RC
