#!/usr/bin/awk -f

BEGIN {
    # make array of regexes for recognizing package managers
    Managers[1] = "sudo pacman"
    Managers[2] = "(sudo )?yay"
    Managers[3] = "(sudo )?pacaur"
}

function IsInstalling(histLine) {
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

function IsUninstalling(histLine) {
    for (i = 1; i <= length(Managers); i++) {
        if (histLine ~ Managers[i] " -R") {
            return 1 # True
        }
    }
    return 0 # False
}

# can't return array, so it must be passed as a parameter then filled
function PackageNames(histLine, result) {
    # empty the result array to avoid problems
    for (i in result) {
        delete result[i]
    }

    b = 0
    for (i = 2; i <= NF; i++) {
        if (b && $i !~ "^[-#]") {
            result[$i] = "You should not see this"
        } else if (!b && $i ~ "^-") {
            b = 1
        } else if ($i ~ "^#") {
            return
        }
    }
}

IsInstalling($0) && IsGrouped($0) {
    PackageNames($0, result)
    for (package in result) {
        Groups[$NF][package] = "You shouldn't see this either"
    }
}

IsUninstalling($0) {
    PackageNames($0, result)

    for (group in Groups) {
        for (uninstalled in result) {
            if (uninstalled in Groups[group]) {
                delete Groups[group][uninstalled]
            }
        }
    }
}
