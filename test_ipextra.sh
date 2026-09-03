#!/bin/bash
# Test script for ipextra
# Author: gamm3r96

echo "=== ipextra Test Suite ==="
echo ""

PASS=0
FAIL=0

# Test function
run_test() {
    local name="$1"
    local input="$2"
    local expected="$3"
    
    result=$(echo "$input" | ./ipextra)
    
    if [ "$result" = "$expected" ]; then
        echo "✓ PASS: $name"
        ((PASS++))
    else
        echo "✗ FAIL: $name"
        echo "  Input:    $input"
        echo "  Expected: $expected"
        echo "  Got:      $result"
        ((FAIL++))
    fi
}

# Test 1: Simple valid IP
run_test "Simple valid IP" "192.168.1.1" "192.168.1.1"

# Test 2: IP with trailing text
run_test "IP with trailing text" "10.0.0.1 some text here" "10.0.0.1"

# Test 3: Multiple lines
input="192.168.1.1
10.0.0.1
172.16.0.1"
expected="192.168.1.1
10.0.0.1
172.16.0.1"
run_test "Multiple IPs on separate lines" "$input" "$expected"

# Test 4: IP at start of line with port
run_test "IP with port notation" "192.168.1.1:8080" "192.168.1.1"

# Test 5: Invalid IP (octet > 255)
run_test "Invalid IP (octet > 255)" "256.1.1.1" ""

# Test 6: Valid boundary IP (255.255.255.255)
run_test "Max valid IP" "255.255.255.255" "255.255.255.255"

# Test 7: Valid boundary IP (0.0.0.0)
run_test "Min valid IP" "0.0.0.0" "0.0.0.0"

# Test 8: Mixed valid and invalid
input="192.168.1.1
300.1.1.1
10.0.0.1"
expected="192.168.1.1
10.0.0.1"
run_test "Mixed valid and invalid IPs" "$input" "$expected"

# Test 9: No IPs in input
run_test "No IPs in input" "hello world no ips here" ""

# Test 10: IP with various trailing chars
run_test "IP with comma" "192.168.1.1, something" "192.168.1.1"

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "All tests passed! ✓"
    exit 0
else
    echo "Some tests failed! ✗"
    exit 1
fi
