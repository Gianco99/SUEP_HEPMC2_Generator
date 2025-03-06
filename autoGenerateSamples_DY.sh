#!/usr/bin/expect -f
set timeout -1
spawn bash generateDY.sh -o /afs/cern.ch/user/g/gdecastr/SUEP_HEPMC2_Generator/output -e /eos/cms/store/group/phys_exotica/SUEPs/ZH_MadAnalysis/simpleDY/
expect {
    "Enter PEM pass phrase" {sleep 1; send "\r"; exp_continue }
    eof
}
