#!/usr/bin/expect -f
set timeout -1
# Run both flavors (mu and ele) with the JPsi generator
foreach mode {mu ele} {
    spawn bash generateJPsi.sh -o /afs/cern.ch/user/g/gdecastr/SUEP_HEPMC2_Generator/output -e /eos/user/g/gdecastr/SUEP/JPsi -m $mode
    expect {
        "Enter PEM pass phrase" {sleep 1; send "\r"; exp_continue }
        eof
    }
}

#!/usr/bin/expect -f
# Usage:
#   ./autoGenerateSamples_JPsi.sh -m mu
#   ./autoGenerateSamples_JPsi.sh --mode ele
#   ./autoGenerateSamples_JPsi.sh           # will prompt

set timeout -1

# --- parse args for -m/--mode or a bare positional 'mu'/'ele' ---
set mode ""
set argc [llength $argv]
for {set i 0} {$i < $argc} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-m" || $arg eq "--mode"} {
        incr i
        if {$i < $argc} {
            set mode [lindex $argv $i]
        }
    } elseif {$mode eq "" && ($arg eq "mu" || $arg eq "ele")} {
        set mode $arg
    }
}

# If no mode provided, prompt the user
if {$mode eq ""} {
    send_user "Select mode (mu/ele): "
    expect_user -re "(.*)\n"
    set mode $expect_out(1,string)
}

# Normalize and validate
set mode [string tolower $mode]
if {![string match "mu" $mode] && ![string match "ele" $mode]} {
    send_user "Error: invalid mode '$mode'. Use 'mu' or 'ele'.\n"
    exit 1
}

# Paths (adjust if needed)
set OUTDIR "/afs/cern.ch/user/g/gdecastr/SUEP_HEPMC2_Generator/output"
set EOSDIR "/eos/user/g/gdecastr/SUEP/JPsi"

# Spawn a single run for the chosen mode
spawn bash generateJPsi.sh -o $OUTDIR -e $EOSDIR -m $mode
expect {
    "Enter PEM pass phrase" {sleep 1; send "\r"; exp_continue }
    eof
}