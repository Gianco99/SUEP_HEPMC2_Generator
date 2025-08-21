#!/usr/bin/expect -f
# Auto-generate J/psi -> e+ e- HepMC samples to hit a target number of ACCEPTED events.
# It writes temporary files to ./output_JPsiDiEle and uploads to EOS:
#   /eos/user/g/gdecastr/HepMCSamples/JPsiDiEle
#
# Usage (defaults to 200k accepted, 50k attempts/run):
#   ./autoGenerateSamples_JPsiDiEle.sh
#
# Optional overrides:
#   ./autoGenerateSamples_JPsiDiEle.sh -t 300000          # target accepted
#   ./autoGenerateSamples_JPsiDiEle.sh -c 75000           # attempts per run
#   ./autoGenerateSamples_JPsiDiEle.sh -i suep-generator:latest
#
# Notes:
# - Assumes filter efficiency ~3% and applies 10% safety.
# - Requires generateJPsi.sh (already handles xrdcp to EOS and cleanup).

set timeout -1

# --- defaults ---
set targetAccepted 200000    ;# desired accepted events
set eventsPerRun   50000     ;# attempted events per container run
set image          "suep-generator:latest"
set effMin         0.03      ;# conservative efficiency
set safety         1.10      ;# 10% headroom

# --- fixed for DiEle ---
set MODE   "ele"
set OUTDIR "output_JPsiDiEle"   ;# local temp folder
set EOSDIR "/eos/user/g/gdecastr/HepMCSamples/JPsiDiEle"

# --- parse optional args ---
set argc [llength $argv]
for {set i 0} {$i < $argc} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        "-t" - "--target" { incr i; if {$i < $argc} { set targetAccepted [lindex $argv $i] } }
        "-c" - "--chunk"  { incr i; if {$i < $argc} { set eventsPerRun   [lindex $argv $i] } }
        "-i" - "--image"  { incr i; if {$i < $argc} { set image          [lindex $argv $i] } }
        default { }
    }
}

# --- ensure local output dir exists ---
if {![file isdirectory $OUTDIR]} { file mkdir $OUTDIR }

# --- compute plan ---
set neededAttempts [expr {int(ceil(($targetAccepted / $effMin) * $safety))}]
set runs           [expr {int(ceil(double($neededAttempts) / double($eventsPerRun)))}]

# --- summary ---
send_user "=== JPsi DiEle plan ===\n"
send_user "Target accepted events : $targetAccepted\n"
send_user "Assumed efficiency     : [format %.2f [expr {$effMin*100}]]% + [expr {int(($safety-1.0)*100)}]% safety\n"
send_user "Attempted per run      : $eventsPerRun\n"
send_user "Total attempted        : $neededAttempts\n"
send_user "Number of runs         : $runs\n"
send_user "Local temp output      : $OUTDIR\n"
send_user "EOS destination        : $EOSDIR\n"
send_user "Docker image           : $image\n"
send_user "========================\n"

# --- run ---
spawn bash generateJPsi.sh -i $image -o $OUTDIR -e $EOSDIR -n $runs -c $eventsPerRun -m $MODE
expect {
    "Enter PEM pass phrase" { sleep 1; send "\r"; exp_continue }
    eof
}