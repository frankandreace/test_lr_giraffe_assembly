#!/usr/bin/awk -f

BEGIN {
    FS="\t"
}

{
    if ($4 != "*") {
        print $1
        print $4
        print $5
        print $11
        print $13
    }
}