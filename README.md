# ipextra
IP address extraction using awk — now with a full CLI.

## Install (Debian/Ubuntu)
```bash
sudo dpkg -i ipextra_1.1-1_all.deb
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
