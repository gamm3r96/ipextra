# ipextra
IP address extraction using awk — now with a full CLI.

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

## Architecture
* `/usr/bin/ipextra` — POSIX sh wrapper implementing the CLI.
* `/usr/share/ipextra/ipextra.awk` — the awk engine (mawk/gawk compatible).

https://github.com/gamm3r96/ipextra/blob/master/awk.png
![Alt text](https://github.com/gamm3r96/ipextra/blob/master/awk.png?raw=true "ipextra @gamm3r96")

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
