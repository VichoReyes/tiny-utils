#!/usr/bin/gawk -f

@include "common.awk"

END {
    for (group in Groups) {
        print "group name: " group
        for (package in Groups[group]) {
            print package
        }
        print ""
    }
}
