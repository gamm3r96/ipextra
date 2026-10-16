# ipextra

> Extract, filter, count and validate IPv4 addresses from any text — files or
> stdin — using a tiny POSIX `sh` wrapper plus a portable awk engine
> (gawk / mawk / busybox awk). Ships as a dependency-free `.deb`.

**Quick start**

```bash
sudo dpkg -i ipextra_1.1-1_all.deb   # install
ipextra < access.log                 # list every IPv4 found
ipextra -u -s *.log                  # unique, numerically sorted, across files
ipextra --help                       # all modes & options
```

| | |
|---|---|
| Language | POSIX sh + awk (no bash/gawk-only features) |
| Dependencies | `awk` only |
| Modes | extract · grep · count · validate |
| Package | `ipextra_1.1-1_all.deb` (arch: all) |
| License | MIT |

## Table of contents
- [Why](#why)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Testing without installing](#testing-without-installing)
- [Architecture](#architecture)
- [Building the .deb from source](#building-the-deb-from-source)
- [Repository layout](#repository-layout)
- [Exit codes](#exit-codes)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Why
`grep -o` can't validate octet ranges, `awk one-liners` are hard to read and
break on embedded IPs like `foo 192.168.1.1 bar`, and heavier tools need
Python or Perl. `ipextra` gives you correct IPv4 extraction with real option
parsing in ~300 lines of shell + awk that run anywhere an awk exists.

## Features
- **Four modes**: `-e` extract IPs, `-g` grep whole lines containing an IP,
  `-c` count, `-V` validate every dotted-number token (OK/BAD).
- **Portable regex engine** tuned for mawk's quirks; correctly handles
  multi-digit octets (`192.168.1.1`), multiple IPs per line, and overlapping
  tails (`1.2.3.4.5` → single match). Rejects `256.1.1.1`, `999.x.x.x`, `1.2.3`.
- `-u` dedupe, `-s` numeric IP sort, `-p REGEX` custom line filter,
  `-q` quiet, `-h/--help`, `--version`.
- Multiple file operands (spaces in names safe), stdin fallback, `--` end-of-options.
- Meaningful exit codes for scripting (see below).

## Installation

### Debian / Ubuntu (.deb)
Download the package, then:

```bash
sudo dpkg -i ipextra_1.1-1_all.deb
```

If `dpkg` reports missing dependencies, repair them with:

```bash
sudo apt --fix-broken install
```

Alternative (apt handles dependencies automatically):

```bash
sudo apt install ./ipextra_1.1-1_all.deb
```

Verify the installation:

```bash
dpkg -s ipextra        # package status
ipextra --version      # should print: ipextra 1.1
which ipextra          # /usr/bin/ipextra
```

### Fedora / RHEL / openSUSE
No RPM is provided; install the two files manually:

```bash
sudo install -m755 build/usr/bin/ipextra        /usr/bin/ipextra
sudo install -m644 build/usr/share/ipextra/ipextra.awk /usr/share/ipextra/ipextra.awk
```

### Alpine / busybox systems
The wrapper only needs POSIX sh and any awk that supports `-f`; busybox awk works out of the box. Use the manual-install commands above.

### Uninstall (Debian/Ubuntu)
```bash
sudo dpkg -r ipextra
```

## Usage
```
ipextra [OPTIONS] [FILE...]
ipextra [OPTIONS] < input.txt
```

Modes:
| Flag | Meaning |
|------|---------|
| `-e`, `--extract`   | print every valid IPv4 found (default) |
| `-g`, `--grep`      | print whole lines that contain an IPv4 |
| `-c`, `--count`     | print how many valid IPv4s were found |
| `-V`, `--validate`  | label each dotted-number token OK or BAD |

Options:
| Flag | Meaning |
|------|---------|
| `-u`, `--unique`        | report each distinct address once |
| `-s`, `--sort`          | sort output numerically by IP |
| `-p`, `--pattern=REGEX` | in grep mode match this regex instead of IPs |
| `-q`, `--quiet`         | suppress informational messages |
| `-h`, `--help`          | show help |
| `--version`             | show version |

Exit status: `0` success, `1` usage error, `2` at least one BAD result in `--validate` mode.

## Examples
```bash
ipextra < access.log              # list all IPs
ipextra -u -s file1 file2         # unique, sorted across files
ipextra -g -p 'server .* up' log  # grep-style line filter
ipextra -c netstat.out            # count addresses
echo 10.0.0.999 | ipextra -V      # validate a token (exit 2)
```

Sample run:

```console
$ printf 'foo 10.0.0.5 bar\nnothing here\n192.168.1.1\nversion 1.2.3\n' | ipextra -u -s
10.0.0.5
192.168.1.1
$ echo 'v1.2.3 and 10.0.0.999' | ipextra -V
BAD 1.2.3
BAD 10.0.0.999
$ echo $?
2
```

## Testing without installing
Run straight from the source tree — no root, no package needed:

```bash
IPEXTRA_AWK=./ipextra.awk ./ipextra.sh --help
IPEXTRA_AWK=./ipextra.awk ./ipextra.sh -u -s < somefile.txt
```

(`IPEXTRA_AWK` points the wrapper at the in-tree awk engine instead of the
installed `/usr/share/ipextra/ipextra.awk`.)

## Architecture
Two small files, one process — no daemons, no config:

* `/usr/bin/ipextra` — POSIX sh wrapper implementing the CLI (option parsing,
  file/stdin handling, exit codes).
* `/usr/share/ipextra/ipextra.awk` — the awk engine (mawk/gawk/busybox
  compatible). The wrapper invokes it with `-v MODE -v UNIQUE -v SORTED
  -v PATTERN -v VERBOSE -v MARKER`.

Flow: `ipextra [opts] [files…]` → wrapper parses options → `awk -f ipextra.awk`
streams input → matches are printed / deduped / sorted inside awk → in
validate mode a marker file lets the wrapper translate "BAD seen" into exit
code 2.

### Regex notes
mawk has no `{n}` interval quantifier and miscompiles three-character classes
like `[0-9][0-9]?[0-9]`, so each octet is built from two-char forms with
dot-anchored backtracking; range validity (0–255) is enforced afterwards by an
octet check inside the engine rather than by the regex itself.

https://github.com/gamm3r96/ipextra/blob/master/awk.png
![ipextra demo](https://github.com/gamm3r96/ipextra/blob/master/awk.png?raw=true "ipextra @gamm3r96")

## Building the .deb from source

```bash
./build_deb.sh        # produces ipextra_1.1-1_all.deb in the repo root
```

Requires `dpkg-deb` (Debian/Ubuntu) or any system with `dpkg-dev`.

## Repository layout

| File          | Purpose                                             |
|---------------|-----------------------------------------------------|
| `ipextra.sh`  | CLI wrapper (options, modes, --help)                |
| `ipextra.awk` | IPv4 extraction engine (runs under gawk/mawk)       |
| `ipextra`     | Legacy one-liner kept for reference                 |
| `build_deb.sh`+ `debian.control` | Debian package build script & template |

## Exit codes

| Code | Meaning                                              |
|------|------------------------------------------------------|
| `0`  | success                                              |
| `1`  | invalid option / usage error / awk library missing   |
| `2`  | at least one `BAD` result in `--validate` mode       |

Use them in scripts, e.g. a CI gate that fails on malformed addresses:

```bash
echo "$CONFIG" | ipextra -V -q || { echo "invalid IPs found"; exit 1; }
```

## Troubleshooting
- **`ipextra: awk library not found at /usr/share/ipextra/ipextra.awk`** — the
  wrapper can't locate the engine; reinstall the package, or point it elsewhere
  with `export IPEXTRA_AWK=/path/to/ipextra.awk`.
- **No output on a file you know contains IPs** — check with `-g` to see whole
  matching lines; tokens like `1.2.3` are intentionally not IPv4.
- **Strange results on very old systems** — ensure your awk supports `-f`
  (GNU awk, mawk and busybox awk all do).
- **Broken dependency report from dpkg** — run `sudo apt --fix-broken install`.

## Contributing
Fork, branch, keep changes POSIX-sh / portable-awk compatible, and test both
from source (`IPEXTRA_AWK=./ipextra.awk ./ipextra.sh …`) and after
`./build_deb.sh && sudo dpkg -i ipextra_*_all.deb`. Bug reports and PRs welcome.

## License
MIT © Gamm3r96 — see the repository for details.
