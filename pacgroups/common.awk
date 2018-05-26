#!/usr/bin/awk -f

BEGIN {
    # make array of regexes for recognizing package managers
    Managers[1] = "sudo pacman"
    Managers[2] = "(sudo )?yay"
    Managers[3] = "(sudo )?pacaur"
}

function IsManager(histLine) {
    for (i = 1; i <= length(Managers); i++) {
        if (histLine ~ Managers[i] " -S[yu]* ") {
            return 1 # True
        }
    }
    return 0 # False
}

function IsGrouped(histLine) {
    return histLine ~ "# *[-_a-zA-Z0-9]+ *$"
}

IsManager($0) && IsGrouped($0) {
    Groups[$NF] = "You should not see this"
}
