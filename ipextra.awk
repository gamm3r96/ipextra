# ipextra.awk - IPv4 extraction engine (author Gamm3r96)
# Controlled via -v options set by the ipextra shell wrapper:
#   MODE=extract|grep|count|validate   VERBOSE=1  UNIQUE=1  SORTED=1
#   PATTERN=<regex> (for grep mode)
# Multiple IPs per line are supported; each match is printed on its own line.

BEGIN {
    # mawk quirks: no {n} interval quantifier, and three-char classes like
    # [0-9][0-9]?[0-9] miscompile; only two-char forms are used here.
    # A greedy [0-9][0-9]? would swallow the first two digits of "192" and
    # then fail to find a dot; anchoring each octet's last digit to a
    # following '.' (or end of string) makes backtracking land on the full
    # dotted token.  The optional trailing "(\\.[0-9])?" picks up the third
    # digit of e.g. "192"; validity is enforced by valid() afterwards.
    O = "[0-9][0-9]?(\\.[0-9]|[0-9]\\.)?[0-9]?(\\.[0-9])?"
    IPRE = O "\\." O "\\." O "\\." O
    if (MODE == "") MODE = "extract"
    BADFOUND = 0
    # Validate candidate tokens at word boundaries so -V reports every
    # dotted-number token, not just those matching the extract regex.
    TOKRE = "[^][ \\t]*\\.[^][ \\t]*"
}

{
    line = $0
    off = 0
    lastip = ""
    if (MODE == "validate") {
        vtmp = line
        while (match(vtmp, TOKRE) > 0) {
            tok = substr(vtmp, RSTART, RLENGTH)
            vtmp = substr(vtmp, RSTART + RLENGTH)
            gsub(/^[^0-9]+|[^0-9.]+$/, "", tok)
            if (tok ~ /\./) {
                if (valid(tok)) print "OK " tok
                else { print "BAD " tok; BADFOUND = 1 }
            }
        }
        next
    }
    while (match(substr(line, off + 1), IPRE) > 0) {
        cand = substr(line, off + RSTART, RLENGTH)
        mend = off + RSTART + RLENGTH - 1
        # Extend a candidate whose final octet has a third digit.  If the
        # three-digit form is invalid but the two-digit prefix is valid
        # (e.g. "256" -> "25"), keep the shorter candidate instead.
        if (substr(line, mend + 1, 1) >= "0" && substr(line, mend + 1, 1) <= "9") {
            cand3 = cand substr(line, mend + 1, 1)
            if (valid(cand3)) {
                cand = cand3
                mend++
            } else if (!valid(cand)) {
                cand = ""
            }
        }
        if (cand == "") { off = mend + 1; continue }
        validip = valid(cand)
        if (validip) lastip = cand
        if (MODE == "validate") {
            # handled in the dedicated validate block above
        } else if (MODE == "count") {
            if (validip) n++
        } else if (MODE != "grep") {
            if (validip) {
                if (!UNIQUE || !(cand in seen)) {
                    seen[cand] = 1
                    if (SORTED) out[++nout] = cand
                    else print cand
                }
            } else if (VERBOSE) {
                printf "skipped invalid candidate: %s\n", cand > "/dev/stderr"
            }
        }
        off = skip_sep(line, mend)
    }
    if (MODE == "grep") {
        hit = 0
        if (PATTERN != "") { if (line ~ PATTERN) hit = 1 }
        else if (lastip != "") hit = 1
        if (hit) {
            print line
            nlines++
        }
    }
}

END {
    if (MODE == "count") print n + 0
    if (MODE == "grep" && VERBOSE) print "matched lines: " nlines + 0 > "/dev/stderr"
    if (MODE == "extract" && SORTED) {
        nout2 = 0
        for (k in seen) tmp[++nout2] = k
        isort(tmp, nout2)
        for (i = 1; i <= nout2; i++) print tmp[i]
    }
    # Communicate BAD-found to the shell wrapper via a marker file.
    if (MODE == "validate" && BADFOUND) {
        if (MARKER != "") print > MARKER
    }
}

# Advance past any '.' plus one digit so the next match() cannot re-find
# the tail of the candidate we just consumed (e.g. ".1.1" of 999.1.1.1).
function skip_sep(ln, pos,    c) {
    if (substr(ln, pos + 1, 1) == ".") {
        c = substr(ln, pos + 2, 1)
        if (c >= "0" && c <= "9") return pos + 2
    }
    return pos + 1
}

function valid(ip,    a, i) {
    split(ip, a, "\\.")
    if (length(a) != 4) return 0
    for (i = 1; i <= 4; i++) {
        if (a[i] !~ /^[0-9]+$/) return 0
        if (length(a[i]) > 1 && a[i] ~ /^0/) return 0
        if (a[i] + 0 > 255) return 0
    }
    return 1
}

function ipkey(ip,    a) {
    split(ip, a, "\\.")
    return ((a[1] * 256 + a[2]) * 256 + a[3]) * 256 + a[4]
}

function isort(arr, n,    i, j, t) {
    for (i = 2; i <= n; i++) {
        t = arr[i]
        j = i - 1
        while (j >= 1 && ipkey(arr[j]) > ipkey(t)) {
            arr[j + 1] = arr[j]
            j--
        }
        arr[j + 1] = t
    }
}
