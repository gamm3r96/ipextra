# ipextra

```
 _____ _____ ____ _  __
|_   _|  ___/ ___| |/ /
  | | | |_ | |   | ' / 
  | | |  _|| |___| . \ 
  |_| |_|   \____|_|\_\
                       
  IP Address Extraction Tool
```

**Author:** gamm3r96

## Description

`ipextra` is a lightweight, high-performance AWK-based utility designed to extract valid IPv4 addresses from unstructured text data. Built for speed and simplicity, it efficiently parses log files, network captures, and any text containing IP addresses.

The tool uses intelligent pattern matching to:
- Identify IPv4 address formats (x.x.x.x where each octet is 0-255)
- Handle IPs embedded in text, URLs, or followed by ports
- Filter out invalid addresses (e.g., 999.999.999.999)
- Process large files quickly with minimal memory footprint

Ideal for system administrators, security analysts, and developers who need to quickly extract IP addresses from logs, configuration files, or network data without installing heavy dependencies.

## Usage

Make the script executable:
```bash
chmod +x ipextra
```

Extract IPs from a file:
```bash
./ipextra < "input_file.txt"
```

Or pipe content directly:
```bash
cat logfile.txt | ./ipextra
echo "192.168.1.1 some text" | ./ipextra
```

## Examples

```bash
# Extract IPs from a log file
./ipextra < /var/log/syslog

# Extract IPs from multiple files
cat *.log | ./ipextra

# Filter and extract unique IPs
./ipextra < data.txt | sort -u
```

## Features

- Fast pattern matching using AWK
- Handles IPs at end of lines with trailing text
- Lightweight and portable (no dependencies)
- Works with stdin or file redirection

## Screenshot

![ipextra](https://github.com/gamm3r96/ipextra/blob/master/awk.png?raw=true "ipextra @gamm3r96")

## License

This project is provided as-is by the author gamm3r96.

## Testing

Run the test suite to verify functionality:

```bash
chmod +x test_ipextra.sh
./test_ipextra.sh
```

The test suite covers:
- Simple valid IPs
- IPs with trailing text
- Multiple IPs on separate lines
- IPs with port notation
- Invalid IPs (octets > 255)
- Boundary values (0.0.0.0 and 255.255.255.255)
- Mixed valid and invalid inputs
