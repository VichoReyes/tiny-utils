#!/usr/bin/awk -f

@include "common.awk"

END {
    for (group in Groups) {
        print group
    }
}
